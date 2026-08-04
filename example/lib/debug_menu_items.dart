// example のデバッグメニューの全項目を 1 か所にまとめたファイル。
//
// メニュー項目は単なるウィジェットでよい。`ListTile`、`SwitchListTile`、
// `ExpansionTile`、複数行の `Column` — `ListView` に入れられるものなら何でも使える。
import 'dart:io' show Platform;

import 'package:debug_menu_overlay/debug_menu_overlay.dart';
import 'package:flutter/material.dart';

import 'debug_sub_pages.dart';

/// [buildExampleDebugMenuItems] が実行時に登録・登録解除する項目の id。
const String networkLogItemId = 'network-log';

/// example が起動時に登録する項目を組み立てる。
///
/// 項目が読む状態 — ここではアプリの [ThemeMode] — は getter とコールバックの組で
/// 渡している。こうすることで、項目は自分がどこにマウントされるかを知らずに済む。
List<DebugMenuItem> buildExampleDebugMenuItems({
  required DebugMenuRegistry registry,
  required ThemeMode Function() themeMode,
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) {
  return <DebugMenuItem>[
    // 読み取り専用の値。
    const DebugMenuItem(
      id: 'version',
      title: 'Version',
      builder: _buildVersionItem,
    ),

    // メニューから操作するアプリの状態。スイッチはコールバック経由で書き戻し、
    // ウィンドウの背後でアプリが新しいテーマでリビルドされる。
    DebugMenuItem(
      id: 'dark-mode',
      title: 'Dark mode',
      builder:
          (BuildContext context, DebugMenuScope scope) => SwitchListTile(
            title: const Text('Dark mode'),
            value: themeMode() == ThemeMode.dark,
            onChanged:
                (bool value) => onThemeModeChanged(
                  value ? ThemeMode.dark : ThemeMode.light,
                ),
          ),
    ),

    // サブページ。デバッグウィンドウ専用の Navigator に push されるので、アプリの
    // ルーター・ルートオブザーバー・画面表示アナリティクスはこれを見ない。
    DebugMenuItem(
      id: 'sub-page',
      title: 'Open a sub page',
      builder:
          (BuildContext context, DebugMenuScope scope) => ListTile(
            title: const Text('Open a sub page'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const ExampleSubPage(),
                  ),
                ),
          ),
    ),

    // 最後にウィンドウを閉じて終わるアクション。「オンボーディングをリセット」
    // 「キャッシュを削除」といった項目はこの形になる。
    DebugMenuItem(
      id: 'snack-bar',
      title: 'Run an action and close',
      builder:
          (BuildContext context, DebugMenuScope scope) => ListTile(
            title: const Text('Run an action and close'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              // `scope.appContext` はホストの context であり、MaterialApp より下に
              // ある。そのためこのタイルがデバッグウィンドウの内側にあっても、
              // アプリの ScaffoldMessenger に到達できる。
              ScaffoldMessenger.of(scope.appContext).showSnackBar(
                const SnackBar(content: Text('Ran a debug action.')),
              );
              scope.close();
            },
          ),
    ),

    // 項目はメニューが開いている間に別の項目を追加・削除できる。ウィンドウが
    // レジストリを購読しているためである。
    DebugMenuItem(
      id: 'toggle-network-log',
      title: 'Toggle the network log entry',
      builder:
          (BuildContext context, DebugMenuScope scope) => ListTile(
            title: const Text('Toggle the network log entry'),
            subtitle: const Text('register() / unregister() at runtime'),
            trailing: const Icon(Icons.swap_vert),
            onTap: () {
              if (!scope.registry.unregister(networkLogItemId)) {
                scope.registry.register(_networkLogItem);
              }
            },
          ),
    ),

    // 特定のプラットフォームだけに出す項目。`visibleWhen` は一覧が構築されるたびに
    // 評価されるので、画面ごとに項目を出したり消したりすることもできる。
    DebugMenuItem(
      id: 'android-exit-reasons',
      title: 'Android exit reasons',
      visibleWhen: () => Platform.isAndroid,
      builder:
          (BuildContext context, DebugMenuScope scope) => ListTile(
            title: const Text('Android exit reasons'),
            subtitle: const Text('Only listed on Android'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const ExitReasonsPage(),
                  ),
                ),
          ),
    ),
  ];
}

Widget _buildVersionItem(BuildContext context, DebugMenuScope scope) =>
    const DebugMenuInfoTile(label: 'Version', value: '1.0.0+1');

final DebugMenuItem _networkLogItem = DebugMenuItem(
  id: networkLogItemId,
  title: 'Network log',
  builder:
      (BuildContext context, DebugMenuScope scope) => const ListTile(
        title: Text('Network log'),
        subtitle: Text('Registered at runtime'),
      ),
);
