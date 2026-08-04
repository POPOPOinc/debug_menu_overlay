# debug_menu_overlay_example

[`debug_menu_overlay`](../) を一通り組み込んだ、実際に動かせるアプリ。

```sh
flutter pub get
flutter run          # iOS / Android の実機またはシミュレーター
```

画面に 4 本指で触れる — シミュレーターやキーボードを繋いだ環境では Cmd+D / Ctrl+D —
とメニューが開く。ウィンドウの外をタップすると閉じる。

## 何を示しているか

| 項目 | 示していること |
| --- | --- |
| Version | `DebugMenuInfoTile` |
| Dark mode | 項目からアプリの状態へ書き戻す（ウィンドウの背後でアプリがリビルドされる） |
| Open a sub page | ウィンドウ専用の `Navigator` の内側での `Navigator.of(context).push` |
| Run an action and close | アプリ階層の参照に `scope.appContext` を使い、そのあと `scope.close()` |
| Toggle the network log entry | メニューを開いたままの `DebugMenuRegistry.register` / `unregister` |
| Android exit reasons | `visibleWhen`。Android でのみ一覧に出る |
| 「Open it from the app」ボタン | アプリの UI からの `DebugMenuScope.of(context).controller.open()` |

## どこに何があるか

- [`lib/main.dart`](lib/main.dart) — ホストの組み込み。`MaterialApp.builder` の中の
  `DebugMenuHost` を `!kReleaseMode` で切り替え、`DebugMenuRegistry` と
  `DebugMenuController` はアプリ側で保持している。
- [`lib/debug_menu_items.dart`](lib/debug_menu_items.dart) — メニューの各項目。
- [`lib/home_page.dart`](lib/home_page.dart) — アプリの画面と、そこからメニューを開く処理。
- [`lib/debug_sub_pages.dart`](lib/debug_sub_pages.dart) — push されるデバッグ画面。
