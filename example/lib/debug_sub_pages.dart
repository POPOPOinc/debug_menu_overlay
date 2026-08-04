import 'package:flutter/material.dart';

/// デバッグ用のサブページ。デバッグウィンドウ専用の [Navigator] の内側に push される。
class ExampleSubPage extends StatelessWidget {
  /// サブページを生成する。
  const ExampleSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sub page')),
      body: const Center(child: Text('Still inside the debug window.')),
    );
  }
}

/// 実際のプラットフォーム限定のデバッグ画面に見立てたダミー。
class ExitReasonsPage extends StatelessWidget {
  /// ページを生成する。
  const ExitReasonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android exit reasons')),
      body: const Center(child: Text('Android-only debug screen.')),
    );
  }
}
