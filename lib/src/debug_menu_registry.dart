import 'package:flutter/foundation.dart';

import 'debug_menu_item.dart';

/// デバッグメニューが表示する項目の一覧。表示順で保持する。
///
/// ホストの `items` 引数で一覧をまとめて渡すか、レジストリを保持しておいて各機能の
/// 初期化に合わせて [register] していく。
class DebugMenuRegistry extends ChangeNotifier {
  /// [items] を保持するレジストリを生成する。
  DebugMenuRegistry({Iterable<DebugMenuItem> items = const <DebugMenuItem>[]})
    : _items = List<DebugMenuItem>.of(items);

  final List<DebugMenuItem> _items;

  /// 登録済みの項目。登録順で返す。
  List<DebugMenuItem> get items => List<DebugMenuItem>.unmodifiable(_items);

  /// [item] を一覧の末尾に追加する。
  ///
  /// [DebugMenuItem.id] が設定されていて、同じ id の項目が既に登録済みの場合は、
  /// 末尾への追加ではなくその項目を同じ位置で置き換える。
  void register(DebugMenuItem item) {
    if (_registerSilently(item)) notifyListeners();
  }

  /// [items] のすべてを追加する。リスナーへの通知は 1 回だけ行う。
  void registerAll(Iterable<DebugMenuItem> items) {
    var changed = false;
    for (final item in items) {
      changed = _registerSilently(item) || changed;
    }
    if (changed) notifyListeners();
  }

  /// [DebugMenuItem.id] が [id] である項目を削除する。
  ///
  /// 実際に削除したかどうかを返す。
  bool unregister(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    _items.removeAt(index);
    notifyListeners();
    return true;
  }

  /// すべての項目を削除する。
  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// 現在表示すべき項目。
  ///
  /// [DebugMenuItem.visibleWhen] はここで評価される。そのためアプリが画面を移動する
  /// のに合わせて項目が現れたり消えたりできる。
  List<DebugMenuItem> resolve() =>
      _items.where((item) => item.isVisible).toList(growable: false);

  bool _registerSilently(DebugMenuItem item) {
    final id = item.id;
    if (id != null) {
      final index = _items.indexWhere((registered) => registered.id == id);
      if (index >= 0) {
        if (_items[index] == item) return false;
        _items[index] = item;
        return true;
      }
    }
    _items.add(item);
    return true;
  }
}
