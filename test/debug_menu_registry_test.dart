import 'package:debug_menu_overlay/debug_menu_overlay.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

DebugMenuItem _item(String title, {String? id, bool Function()? visibleWhen}) {
  return DebugMenuItem(
    id: id,
    title: title,
    visibleWhen: visibleWhen,
    builder:
        (BuildContext context, DebugMenuScope scope) => const SizedBox.shrink(),
  );
}

void main() {
  test('登録順を保つ', () {
    final registry = DebugMenuRegistry(items: <DebugMenuItem>[_item('a')]);
    registry.register(_item('b'));
    registry.register(_item('c'));

    expect(registry.items.map((DebugMenuItem item) => item.title), <String>[
      'a',
      'b',
      'c',
    ]);
  });

  test('同じ id の項目は同じ位置で置き換える', () {
    final registry = DebugMenuRegistry(
      items: <DebugMenuItem>[_item('a', id: 'a'), _item('b', id: 'b')],
    );

    registry.register(_item('a2', id: 'a'));

    expect(registry.items.map((DebugMenuItem item) => item.title), <String>[
      'a2',
      'b',
    ]);
  });

  test('unregister は id で削除し、削除したかどうかを返す', () {
    final registry = DebugMenuRegistry(
      items: <DebugMenuItem>[_item('a', id: 'a')],
    );

    expect(registry.unregister('missing'), isFalse);
    expect(registry.unregister('a'), isTrue);
    expect(registry.items, isEmpty);
  });

  test('registerAll の通知は 1 回だけ', () {
    final registry = DebugMenuRegistry();
    var notifications = 0;
    registry.addListener(() => notifications++);

    registry.registerAll(<DebugMenuItem>[_item('a'), _item('b'), _item('c')]);

    expect(notifications, 1);
    expect(registry.items, hasLength(3));
  });

  test('resolve は visibleWhen が false の項目を落とす', () {
    var visible = false;
    final registry = DebugMenuRegistry(
      items: <DebugMenuItem>[
        _item('always'),
        _item('sometimes', visibleWhen: () => visible),
      ],
    );

    expect(registry.resolve(), hasLength(1));

    visible = true;

    expect(registry.resolve(), hasLength(2));
  });
}
