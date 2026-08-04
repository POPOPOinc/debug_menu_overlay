// debug_menu_overlay を組み込んだ最小構成のアプリ。
//
// 画面に 4 本指で触れる — または Cmd+D / Ctrl+D を押す — とデバッグメニューが開く。
// ウィンドウの外をタップすると閉じる。
import 'package:debug_menu_overlay/debug_menu_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'debug_menu_items.dart';
import 'home_page.dart';

void main() => runApp(const ExampleApp());

/// example アプリ本体。
class ExampleApp extends StatefulWidget {
  /// example アプリを生成する。
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  /// アプリ側で保持している。各機能が任意のタイミングで自分の項目を登録できるように
  /// し、かつ起動ジェスチャー以外からもメニューを開けるようにするためである。
  final DebugMenuRegistry _registry = DebugMenuRegistry();
  final DebugMenuController _controller = DebugMenuController();

  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _registry.registerAll(
      buildExampleDebugMenuItems(
        registry: _registry,
        themeMode: () => _themeMode,
        onThemeModeChanged:
            (ThemeMode mode) => setState(() => _themeMode = mode),
      ),
    );
  }

  @override
  void dispose() {
    _registry.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'debug_menu_overlay',
      themeMode: _themeMode,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      // ホストは MaterialApp より下にある — そのためウィンドウがテーマ・文字方向・
      // MediaQuery・material のローカライズを継承できる — と同時にアプリ自身の
      // ウィジェットより上にあるので、項目は `DebugMenuScope.appContext` を通じて
      // アプリの状態に到達できる。
      builder:
          (BuildContext context, Widget? child) => DebugMenuHost(
            // リリースビルドでは決して到達しない。メニュー全体が tree shaking で
            // 取り除かれる。
            enabled: !kReleaseMode,
            controller: _controller,
            registry: _registry,
            title: 'Example debug menu',
            theme: const DebugMenuWindowTheme(
              widthFactor: 0.85,
              heightFactor: 0.75,
              barrierColor: Color(0x33000000),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: child!,
          ),
      home: const HomePage(),
    );
  }
}
