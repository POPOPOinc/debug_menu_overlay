import 'package:flutter/material.dart';

import 'debug_menu_list_page.dart';
import 'debug_menu_scope.dart';
import 'debug_menu_theme.dart';

/// デバッグウィンドウ。タップで閉じるバリアと、専用の [Navigator] を持つ
/// フローティングパネルからなる。
///
/// [Positioned] を返すため、ホストの `Stack` の直接の子として使うことを想定して
/// いる。
class DebugMenuWindow extends StatefulWidget {
  /// ウィンドウを生成する。
  const DebugMenuWindow({
    required this.scope,
    required this.theme,
    required this.title,
    super.key,
  });

  /// ホストのスコープ。すべての項目ビルダーに渡される。
  final DebugMenuScope scope;

  /// ウィンドウの見た目。
  final DebugMenuWindowTheme theme;

  /// ウィンドウのヘッダーに表示するテキスト。
  final String title;

  @override
  State<DebugMenuWindow> createState() => _DebugMenuWindowState();
}

class _DebugMenuWindowState extends State<DebugMenuWindow> {
  /// このウィンドウ専用の hero コントローラー。
  ///
  /// [HeroController] は一度に 1 つの [Navigator] しか担当できない。そしてホストは
  /// `MaterialApp` より下に置かれることが多く、その `MaterialApp` のコントローラーは
  /// すでにアプリの navigator を担当している。自前のものを持たないと、ウィンドウを
  /// マウントした時点でその assert に引っかかってしまう。
  final HeroController _heroController =
      MaterialApp.createMaterialHeroController();

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final media = MediaQuery.maybeOf(context);
    // ノッチを避け、かつソフトキーボードの分だけ縮む。項目がテキストフィールドを
    // 含んでいても隠れないようにするためである。
    final inset =
        (media?.padding ?? EdgeInsets.zero) +
        (media?.viewInsets ?? EdgeInsets.zero);

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.scope.close,
              child: ColoredBox(color: theme.barrierColor),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: inset,
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: theme.widthFactor,
                  heightFactor: theme.heightFactor,
                  child: _buildPanel(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final theme = widget.theme;
    final hasRadius = theme.borderRadius != BorderRadius.zero;
    return Material(
      color: theme.backgroundColor,
      borderRadius: hasRadius ? theme.borderRadius : null,
      clipBehavior: hasRadius ? Clip.antiAlias : Clip.none,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.borderColor ?? Theme.of(context).dividerColor,
            width: theme.borderWidth,
          ),
          borderRadius: theme.borderRadius,
        ),
        // デバッグメニュー専用の Navigator。項目が push したサブページはこの
        // ウィンドウの内側に留まる。アプリのルーター・ルートオブザーバー・
        // 画面表示アナリティクスはそれらを一切見ない。
        child: HeroControllerScope(
          controller: _heroController,
          child: Navigator(
            onGenerateRoute:
                (RouteSettings settings) => PageRouteBuilder<void>(
                  settings: settings,
                  pageBuilder:
                      (
                        BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                      ) => DebugMenuListPage(
                        scope: widget.scope,
                        title: widget.title,
                      ),
                ),
          ),
        ),
      ),
    );
  }
}
