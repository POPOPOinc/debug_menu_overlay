import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// デバッグメニューを開くハードウェアキーボードの組み合わせ。
///
/// 4本指タップがやりにくいシミュレーター・デスクトップ・キーボードを繋いだ iPad で
/// 重宝する。
@immutable
class DebugMenuKeyboardShortcut {
  /// ショートカットを生成する。既定は Cmd+D / Ctrl+D。
  const DebugMenuKeyboardShortcut({
    this.key = LogicalKeyboardKey.keyD,
    this.requireMetaOrControl = true,
  });

  /// メニューを開くキー。
  final LogicalKeyboardKey key;

  /// Meta（macOS の Command）または Control の同時押しを必要とするかどうか。
  final bool requireMetaOrControl;

  @override
  bool operator ==(Object other) =>
      other is DebugMenuKeyboardShortcut &&
      other.key == key &&
      other.requireMetaOrControl == requireMetaOrControl;

  @override
  int get hashCode => Object.hash(key, requireMetaOrControl);
}

/// ユーザーがデバッグメニューを開く方法。
@immutable
class DebugMenuActivation {
  /// 起動方法の設定を生成する。
  const DebugMenuActivation({
    this.pointerCount = 4,
    this.keyboardShortcut = const DebugMenuKeyboardShortcut(),
  });

  /// 何もメニューを開かない。`DebugMenuController.open` だけが唯一の手段になる。
  static const DebugMenuActivation none = DebugMenuActivation(
    pointerCount: 0,
    keyboardShortcut: null,
  );

  /// 同時に画面へ触れている必要がある指の本数。
  ///
  /// 既定の 4 本が扱いやすい。ユーザーが誤って触れてしまう本数ではなく、かつ
  /// トリプルタップと違ってタイムアウトを待つ必要がないため、アプリ自身の
  /// ジェスチャーを遅延させたり奪ったりすることがない。0 にすると無効になる。
  final int pointerCount;

  /// メニューを開くキーボードの組み合わせ。null にすると無効になる。
  final DebugMenuKeyboardShortcut? keyboardShortcut;

  @override
  bool operator ==(Object other) =>
      other is DebugMenuActivation &&
      other.pointerCount == pointerCount &&
      other.keyboardShortcut == keyboardShortcut;

  @override
  int get hashCode => Object.hash(pointerCount, keyboardShortcut);
}
