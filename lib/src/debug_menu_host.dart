import 'package:flutter/widgets.dart';

import 'debug_menu_activation.dart';
import 'debug_menu_activation_detector.dart';
import 'debug_menu_controller.dart';
import 'debug_menu_item.dart';
import 'debug_menu_registry.dart';
import 'debug_menu_scope.dart';
import 'debug_menu_theme.dart';
import 'debug_menu_window.dart';

/// アプリをラップし、複数本指のタップでデバッグメニューを表示する。
///
/// `MaterialApp` より下に置くこと — `MaterialApp.builder` の中か、`home` に渡す
/// ウィジェットを包む形にする。そうすればウィンドウがテーマ・文字方向・MediaQuery・
/// material のローカライズを継承できる。同時に、項目が必要とする InheritedWidget
/// （redux ストア、provider のスコープなど）より下に置く必要もある。
/// [DebugMenuScope.appContext] はホスト自身の context である。
///
/// ```dart
/// DebugMenuHost(
///   enabled: !kReleaseMode,
///   items: <DebugMenuItem>[
///     DebugMenuItem(
///       title: 'Reset onboarding',
///       builder: (context, scope) => ListTile(
///         title: const Text('Reset onboarding'),
///         onTap: () {
///           resetOnboarding();
///           scope.close();
///         },
///       ),
///     ),
///   ],
///   child: child,
/// )
/// ```
///
/// [enabled] が false のとき、ホストは [child] だけを構築する — ジェスチャー
/// ディテクターも Listener もウィンドウも作らない。本番ビルドでメニューを開けない
/// ようにするため、flavor か `kReleaseMode` で切り替えること。
class DebugMenuHost extends StatelessWidget {
  /// ホストを生成する。
  const DebugMenuHost({
    required this.child,
    this.enabled = true,
    this.controller,
    this.registry,
    this.items,
    this.activation = const DebugMenuActivation(),
    this.onActivate,
    this.theme = const DebugMenuWindowTheme(),
    this.title = 'Debug Menu',
    super.key,
  }) : assert(
         registry == null || items == null,
         'registry と items は両方ではなく、どちらか一方を渡すこと。',
       );

  /// デバッグメニューを上に重ねる対象のアプリ。
  final Widget child;

  /// デバッグメニューをそもそも存在させるかどうか。
  final bool enabled;

  /// ウィンドウを開閉する。null の場合は内部で 1 つ生成する。
  final DebugMenuController? controller;

  /// 一覧表示する項目。null の場合は [items] から 1 つ生成する。
  ///
  /// 各機能の初期化に合わせて後から項目を登録したい場合は、[items] ではなく
  /// レジストリを渡す。
  final DebugMenuRegistry? registry;

  /// 一覧表示する項目。最初からすべて揃っている場合に使う。
  ///
  /// ホストのマウント時に一度だけ読まれ、その後は二度と読まれない。項目が
  /// [DebugMenuScope.registry] を通じて実行時に登録したエントリが、アプリの次の
  /// リビルドで失われないようにするためである。マウント後にこのリストを変更しても
  /// 無視され、デバッグモードではエラーとして報告される。項目の集合そのものを
  /// 変えたい場合は [registry] を渡し、項目を出したり隠したりしたいだけの場合は
  /// [DebugMenuItem.visibleWhen] を使うこと。
  final List<DebugMenuItem>? items;

  /// 何でメニューを開くか。
  final DebugMenuActivation activation;

  /// ウィンドウを直接開く代わりに呼ばれる。
  ///
  /// メニューを開く処理をアプリ側の状態管理を経由させたいときに使う — ここで
  /// アクションを dispatch し、その結果で [controller] を動かす。こうすると
  /// メニューを開くすべての経路が同じ挙動になる。
  final VoidCallback? onActivate;

  /// ウィンドウの見た目。
  final DebugMenuWindowTheme theme;

  /// ウィンドウのヘッダーに表示するテキスト。
  final String title;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return _DebugMenuHostBody(
      controller: controller,
      registry: registry,
      items: items,
      activation: activation,
      onActivate: onActivate,
      theme: theme,
      title: title,
      child: child,
    );
  }
}

class _DebugMenuHostBody extends StatefulWidget {
  const _DebugMenuHostBody({
    required this.child,
    required this.controller,
    required this.registry,
    required this.items,
    required this.activation,
    required this.onActivate,
    required this.theme,
    required this.title,
  });

  final Widget child;
  final DebugMenuController? controller;
  final DebugMenuRegistry? registry;
  final List<DebugMenuItem>? items;
  final DebugMenuActivation activation;
  final VoidCallback? onActivate;
  final DebugMenuWindowTheme theme;
  final String title;

  @override
  State<_DebugMenuHostBody> createState() => _DebugMenuHostBodyState();
}

class _DebugMenuHostBodyState extends State<_DebugMenuHostBody> {
  late DebugMenuController _controller;
  late DebugMenuRegistry _registry;
  bool _ownsController = false;
  bool _ownsRegistry = false;

  @override
  void initState() {
    super.initState();
    _attachController();
    _attachRegistry();
  }

  @override
  void didUpdateWidget(_DebugMenuHostBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController();
    }
    // 使用中のレジストリを差し替えるのは、レジストリ自体が別物になったときだけ。
    // `items` を意図的に読み直さないのは、これが通常インラインのリストリテラルで
    // 渡され、リビルドごとに別インスタンスになるためである。そこからレジストリを
    // 作り直すと、実行時に登録されたものがすべて捨てられてしまう。
    if (widget.registry != oldWidget.registry) {
      _detachRegistry();
      _attachRegistry();
    } else {
      assert(_debugReportItemsChanged(oldWidget.items, widget.items));
    }
  }

  @override
  void dispose() {
    _detachController();
    _detachRegistry();
    super.dispose();
  }

  void _attachController() {
    final provided = widget.controller;
    _ownsController = provided == null;
    _controller = provided ?? DebugMenuController();
    _controller.addListener(_handleControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _attachRegistry() {
    final provided = widget.registry;
    _ownsRegistry = provided == null;
    _registry =
        provided ??
        DebugMenuRegistry(items: widget.items ?? const <DebugMenuItem>[]);
  }

  void _detachRegistry() {
    if (_ownsRegistry) _registry.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  /// [items] がマウント時と同じエントリを表さなくなった場合に、デバッグモードで
  /// エラーを報告する。無視された変更を無音にしないためである。
  ///
  /// assert ではなく報告にしているのは、これが [didUpdateWidget] の中で走るため。
  /// ここで例外を投げるとリビルドが巻き戻り、本来のメッセージがフレームワーク側の
  /// 二次エラーの山に埋もれてしまう。
  ///
  /// [DebugMenuItem.builder] は通常ウィジェットと一緒に作り直されるクロージャなので、
  /// 項目を等価性で比較することはできない。リビルドをまたいで安定しているのは
  /// id と title の部分である。
  static bool _debugReportItemsChanged(
    List<DebugMenuItem>? oldItems,
    List<DebugMenuItem>? newItems,
  ) {
    String signature(List<DebugMenuItem>? items) =>
        (items ?? const <DebugMenuItem>[])
            .map((DebugMenuItem item) => '${item.id}:${item.title}')
            .join(', ');

    final was = signature(oldItems);
    final now = signature(newItems);
    if (was != now) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
              'ホストのマウント後に DebugMenuHost.items が変更されたが、その変更は '
              '無視された。',
            ),
            ErrorDescription(
              'items はマウント時に一度だけ読まれる。実行時に登録されたエントリを '
              '次のリビルドで捨ててしまわないようにするためである。',
            ),
            ErrorHint(
              '項目の集合そのものを変えたい場合は DebugMenuRegistry を渡し、項目を '
              '出したり隠したりしたいだけの場合は DebugMenuItem.visibleWhen を '
              '使うこと。',
            ),
            ErrorDescription('変更前: [$was]'),
            ErrorDescription('変更後: [$now]'),
          ]),
          library: 'debug_menu_overlay',
          context: ErrorDescription('DebugMenuHost のリビルド中'),
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scope = DebugMenuScope(
      controller: _controller,
      registry: _registry,
      appContext: context,
    );

    Widget stack = Stack(
      children: <Widget>[
        widget.child,
        if (_controller.isOpen)
          DebugMenuWindow(
            scope: scope,
            theme: widget.theme,
            title: widget.title,
          ),
      ],
    );

    // Stack は周囲の文字方向を見て alignment を解決する。ホストがアプリ全体を
    // ラップしている場合、文字方向が存在しないことも正当にありえる。
    if (Directionality.maybeOf(context) == null) {
      stack = Directionality(textDirection: TextDirection.ltr, child: stack);
    }

    return InheritedDebugMenuScope(
      scope: scope,
      child: DebugMenuActivationDetector(
        activation: widget.activation,
        onActivate: widget.onActivate ?? _controller.open,
        child: stack,
      ),
    );
  }
}
