import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'debug_menu_activation.dart';

/// デバッグメニューの起動ジェスチャーとキーボードショートカットを監視する。
///
/// ポインタは [Listener] で観測する。[Listener] はジェスチャーアリーナに参加しない
/// ため、アプリ自身のタップ・ドラッグ・スクロールに影響しない。キーボード
/// ショートカットは [HardwareKeyboard] で観測する。フォーカスを持つ
/// `KeyboardListener` と違い、アプリのテキストフィールドからフォーカスを奪わない。
class DebugMenuActivationDetector extends StatefulWidget {
  /// ディテクターを生成する。
  const DebugMenuActivationDetector({
    required this.activation,
    required this.onActivate,
    required this.child,
    super.key,
  });

  /// 何を起動とみなすか。
  final DebugMenuActivation activation;

  /// 起動ジェスチャーまたはショートカットが行われたときに呼ばれる。
  final VoidCallback onActivate;

  /// ジェスチャーを観測する対象のサブツリー。
  final Widget child;

  @override
  State<DebugMenuActivationDetector> createState() =>
      _DebugMenuActivationDetectorState();
}

class _DebugMenuActivationDetectorState
    extends State<DebugMenuActivationDetector> {
  final Set<int> _activePointers = <int>{};
  bool _keyHandlerAdded = false;

  @override
  void initState() {
    super.initState();
    _syncKeyHandler();
  }

  @override
  void didUpdateWidget(DebugMenuActivationDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeyHandler();
  }

  @override
  void dispose() {
    if (_keyHandlerAdded) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
      _keyHandlerAdded = false;
    }
    super.dispose();
  }

  void _syncKeyHandler() {
    final wanted = widget.activation.keyboardShortcut != null;
    if (wanted == _keyHandlerAdded) return;
    if (wanted) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    _keyHandlerAdded = wanted;
  }

  bool _handleKeyEvent(KeyEvent event) {
    final shortcut = widget.activation.keyboardShortcut;
    if (shortcut == null) return false;
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != shortcut.key) return false;
    if (shortcut.requireMetaOrControl &&
        !HardwareKeyboard.instance.isMetaPressed &&
        !HardwareKeyboard.instance.isControlPressed) {
      return false;
    }
    widget.onActivate();
    return true;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final requiredCount = widget.activation.pointerCount;
    _activePointers.add(event.pointer);
    // `>=` ではなく `==` にしている。メニューが開き始めているときに 5 本目の指が
    // 触れても、再度起動してはならない。
    if (_activePointers.length == requiredCount) {
      widget.onActivate();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activation.pointerCount <= 0) return widget.child;
    return Listener(
      // translucent にしているのは、アプリ自身のヒットテストの隙間に落ちた
      // ポインタも数に入れるため。アリーナから何かを取り除くことはしない。
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: (event) => _activePointers.remove(event.pointer),
      onPointerCancel: (event) => _activePointers.remove(event.pointer),
      child: widget.child,
    );
  }
}
