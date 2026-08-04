import 'package:flutter/widgets.dart';

import 'debug_menu_controller.dart';
import 'debug_menu_registry.dart';

/// デバッグメニューの項目がホストから必要とするものすべて。
///
/// すべての [DebugMenuItem.builder] に渡される。ホストより下であれば
/// [DebugMenuScope.of] でどこからでも取得できる。
@immutable
class DebugMenuScope {
  /// スコープを生成する。ホストが構築するので、自分で生成することはほとんどない。
  const DebugMenuScope({
    required this.controller,
    required this.registry,
    required this.appContext,
  });

  /// デバッグウィンドウを開閉する。
  final DebugMenuController controller;

  /// デバッグウィンドウが一覧表示する項目。
  final DebugMenuRegistry registry;

  /// ホストウィジェット自身の `BuildContext`。
  ///
  /// 項目はホストの子孫であるデバッグウィンドウの内側で構築されるので、項目自身の
  /// context からでも同じ祖先には到達できる。[appContext] があるのは、項目を
  /// 「アプリの context を引数で受け取る素のウィジェット」として書けるようにする
  /// ためである。自分がどこにマウントされるかを知らずに済むので、ホストより上にある
  /// redux ストアの参照・provider の read・サービスロケーターの解決に向いている。
  final BuildContext appContext;

  /// デバッグウィンドウを閉じる。
  void close() => controller.close();

  /// 最も近い外側のホストのスコープ。
  ///
  /// [context] より上にホストがない場合、デバッグモードでは例外を投げる。
  static DebugMenuScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, '渡された context より上に DebugMenuHost が見つからない。');
    return scope!;
  }

  /// 最も近い外側のホストのスコープ。存在しない場合は null。
  static DebugMenuScope? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<InheritedDebugMenuScope>()
          ?.scope;
}

/// ホストより下のサブツリーに [DebugMenuScope] を公開する。
///
/// パッケージ内部用。外部には export していない。
class InheritedDebugMenuScope extends InheritedWidget {
  /// 継承スコープの保持ウィジェットを生成する。
  const InheritedDebugMenuScope({
    required this.scope,
    required super.child,
    super.key,
  });

  /// 子孫に渡すスコープ。
  final DebugMenuScope scope;

  @override
  bool updateShouldNotify(InheritedDebugMenuScope oldWidget) =>
      scope.controller != oldWidget.scope.controller ||
      scope.registry != oldWidget.scope.registry ||
      scope.appContext != oldWidget.scope.appContext;
}
