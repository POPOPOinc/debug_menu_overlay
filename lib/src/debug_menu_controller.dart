import 'package:flutter/foundation.dart';

/// デバッグメニューのウィンドウを開閉する。
///
/// 起動ジェスチャー以外の場所からメニューを開く必要があるとき — ディープリンク、
/// シェイク検出、redux のアクション、テスト用のフックなど — は、これをアプリ側の
/// 状態管理層で保持する。
class DebugMenuController extends ChangeNotifier {
  /// コントローラーを生成する。
  DebugMenuController({bool isOpen = false}) : _isOpen = isOpen;

  bool _isOpen;

  /// デバッグウィンドウが現在表示されているかどうか。
  bool get isOpen => _isOpen;

  /// デバッグウィンドウを表示する。すでに開いている場合は何もしない。
  void open() => _setOpen(true);

  /// デバッグウィンドウを閉じる。すでに閉じている場合は何もしない。
  void close() => _setOpen(false);

  /// 閉じているなら開き、開いているなら閉じる。
  void toggle() => _setOpen(!_isOpen);

  void _setOpen(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
  }
}
