import 'package:flutter/widgets.dart';

/// デバッグウィンドウ自体の見た目。
///
/// 既定では、完全に透明なバリアの上に画面の 70% を占める枠線付きのボックスを
/// 表示する。メニューを操作している間もアプリが背後に見えたままになる。
@immutable
class DebugMenuWindowTheme {
  /// ウィンドウテーマを生成する。
  const DebugMenuWindowTheme({
    this.widthFactor = 0.7,
    this.heightFactor = 0.7,
    this.barrierColor = const Color(0x00000000),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = BorderRadius.zero,
  });

  /// 利用可能な幅に対する比率で表したウィンドウの幅。
  final double widthFactor;

  /// 利用可能な高さに対する比率で表したウィンドウの高さ。
  final double heightFactor;

  /// ウィンドウの背後でアプリの上に塗られる色。
  ///
  /// 不透明度に関係なく、タップするとメニューが閉じる。
  final Color barrierColor;

  /// ウィンドウの背景色。未指定なら周囲のテーマの canvas 色にフォールバックする。
  final Color? backgroundColor;

  /// ウィンドウの枠線色。未指定なら周囲のテーマの divider 色にフォールバックする。
  final Color? borderColor;

  /// ウィンドウの枠線の太さ。
  final double borderWidth;

  /// ウィンドウの角の丸み。
  final BorderRadius borderRadius;
}
