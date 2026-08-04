import 'package:debug_menu_overlay/debug_menu_overlay.dart';
import 'package:flutter/material.dart';

/// このアプリの唯一の画面。
///
/// [DebugMenuHost] より下にあるため [DebugMenuScope.of] でホストが見つかり、アプリ側
/// からメニューを開ける。ディープリンク・シェイク検出・QA ビルドの「バグを報告」
/// ボタンなども同じやり方で開ける。
class HomePage extends StatelessWidget {
  /// ホーム画面を生成する。
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('debug_menu_overlay')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tap with four fingers, or press Cmd+D / Ctrl+D, to open the '
                'debug menu.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => DebugMenuScope.of(context).controller.open(),
              child: const Text('Open it from the app'),
            ),
          ],
        ),
      ),
    );
  }
}
