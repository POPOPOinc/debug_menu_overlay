import 'package:flutter/material.dart';

import 'debug_menu_scope.dart';

/// デバッグウィンドウのルートページ。登録済みの項目を一覧表示する。
///
/// ウィンドウ専用の [Navigator] の最初のルートとして push される。そのため項目が
/// サブページを push すると、このページは完全に置き換わる — 通常の画面と同じ
/// 振る舞いになる。
class DebugMenuListPage extends StatelessWidget {
  /// 一覧ページを生成する。
  const DebugMenuListPage({
    required this.scope,
    required this.title,
    super.key,
  });

  /// ホストのスコープ。すべての項目ビルダーに渡される。
  final DebugMenuScope scope;

  /// ウィンドウのヘッダーに表示するテキスト。
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scope.registry,
      builder: (BuildContext context, Widget? _) {
        final items = scope.registry.resolve();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context),
            Expanded(
              child:
                  items.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        itemBuilder:
                            (BuildContext context, int index) =>
                                items[index].builder(context, scope),
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20,
              onPressed: scope.close,
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No debug menu items registered.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
