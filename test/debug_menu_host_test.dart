import 'package:debug_menu_overlay/debug_menu_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  DebugMenuController? controller,
  DebugMenuRegistry? registry,
  List<DebugMenuItem>? items,
  bool enabled = true,
  DebugMenuActivation activation = const DebugMenuActivation(),
  VoidCallback? onActivate,
}) {
  return MaterialApp(
    home: DebugMenuHost(
      controller: controller,
      registry: registry,
      items: items,
      enabled: enabled,
      activation: activation,
      onActivate: onActivate,
      child: const Scaffold(body: Center(child: Text('app'))),
    ),
  );
}

DebugMenuItem _tile(String label, {bool Function()? visibleWhen}) {
  return DebugMenuItem(
    title: label,
    visibleWhen: visibleWhen,
    builder:
        (BuildContext context, DebugMenuScope scope) =>
            ListTile(title: Text(label)),
  );
}

/// [count] 本の指を同時に置き、そのあと離す。
Future<void> _tapWithFingers(WidgetTester tester, int count) async {
  final gestures = <TestGesture>[];
  for (var index = 0; index < count; index++) {
    gestures.add(
      await tester.startGesture(
        Offset(20 + index * 20, 20),
        pointer: index + 1,
      ),
    );
  }
  await tester.pump();
  for (final gesture in gestures) {
    await gesture.up();
  }
  await tester.pump();
}

void main() {
  testWidgets('4 本指のタップでメニューが開く', (WidgetTester tester) async {
    await tester.pumpWidget(_app(items: <DebugMenuItem>[_tile('Ping')]));

    expect(find.text('Ping'), findsNothing);

    await _tapWithFingers(tester, 4);

    expect(find.text('Ping'), findsOneWidget);
    // アプリはウィンドウの背後にマウントされたまま。
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('3 本指では開かない', (WidgetTester tester) async {
    await tester.pumpWidget(_app(items: <DebugMenuItem>[_tile('Ping')]));

    await _tapWithFingers(tester, 3);

    expect(find.text('Ping'), findsNothing);
  });

  testWidgets('指の本数は設定できる', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(
        items: <DebugMenuItem>[_tile('Ping')],
        activation: const DebugMenuActivation(pointerCount: 2),
      ),
    );

    await _tapWithFingers(tester, 2);

    expect(find.text('Ping'), findsOneWidget);
  });

  testWidgets('キーボードショートカットでメニューが開く', (WidgetTester tester) async {
    await tester.pumpWidget(_app(items: <DebugMenuItem>[_tile('Ping')]));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
    await tester.pump();

    expect(find.text('Ping'), findsOneWidget);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  });

  testWidgets('修飾キーなしのショートカットでは何も起きない', (WidgetTester tester) async {
    await tester.pumpWidget(_app(items: <DebugMenuItem>[_tile('Ping')]));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
    await tester.pump();

    expect(find.text('Ping'), findsNothing);

    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
  });

  testWidgets('ウィンドウの外をタップすると閉じる', (WidgetTester tester) async {
    final controller = DebugMenuController(isOpen: true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(controller: controller, items: <DebugMenuItem>[_tile('Ping')]),
    );

    expect(find.text('Ping'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();

    expect(find.text('Ping'), findsNothing);
    expect(controller.isOpen, isFalse);
  });

  testWidgets('onActivate はウィンドウを直接開く動作を置き換える', (WidgetTester tester) async {
    var activations = 0;
    await tester.pumpWidget(
      _app(
        items: <DebugMenuItem>[_tile('Ping')],
        onActivate: () => activations++,
      ),
    );

    await _tapWithFingers(tester, 4);

    expect(activations, 1);
    expect(find.text('Ping'), findsNothing);
  });

  testWidgets('無効なときは何も組み込まれない', (WidgetTester tester) async {
    final controller = DebugMenuController(isOpen: true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        controller: controller,
        items: <DebugMenuItem>[_tile('Ping')],
        enabled: false,
      ),
    );

    expect(find.text('Ping'), findsNothing);
    expect(find.text('app'), findsOneWidget);

    await _tapWithFingers(tester, 4);

    expect(find.text('Ping'), findsNothing);
  });

  testWidgets('隠れている項目は一覧に出ない', (WidgetTester tester) async {
    var visible = false;
    final controller = DebugMenuController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        controller: controller,
        items: <DebugMenuItem>[
          _tile('Always'),
          _tile('Sometimes', visibleWhen: () => visible),
        ],
      ),
    );

    controller.open();
    await tester.pump();

    expect(find.text('Always'), findsOneWidget);
    expect(find.text('Sometimes'), findsNothing);

    visible = true;
    controller.close();
    await tester.pump();
    controller.open();
    await tester.pump();

    expect(find.text('Sometimes'), findsOneWidget);
  });

  testWidgets('メニューを開いている間に登録した項目が現れる', (WidgetTester tester) async {
    final controller = DebugMenuController(isOpen: true);
    final registry = DebugMenuRegistry();
    addTearDown(controller.dispose);
    addTearDown(registry.dispose);
    await tester.pumpWidget(_app(controller: controller, registry: registry));

    expect(find.text('No debug menu items registered.'), findsOneWidget);

    registry.register(_tile('Late'));
    await tester.pump();

    expect(find.text('Late'), findsOneWidget);
  });

  testWidgets('項目はウィンドウの内側にサブページを push できる', (WidgetTester tester) async {
    final controller = DebugMenuController(isOpen: true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        controller: controller,
        items: <DebugMenuItem>[
          DebugMenuItem(
            title: 'Push',
            builder:
                (BuildContext context, DebugMenuScope scope) => ListTile(
                  title: const Text('Push'),
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (BuildContext context) =>
                                  const Scaffold(body: Text('sub page')),
                        ),
                      ),
                ),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Push'));
    await tester.pumpAndSettle();

    expect(find.text('sub page'), findsOneWidget);
    // アプリ自身の navigator には触れていない。
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('ホストが MaterialApp.builder にあってもウィンドウが開く', (
    WidgetTester tester,
  ) async {
    // この場合ホストはアプリ自身の navigator の下ではなく横に並ぶ。そのため
    // ウィンドウは MaterialApp の hero コントローラーを再利用してはならない。
    final controller = DebugMenuController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder:
            (BuildContext context, Widget? child) => DebugMenuHost(
              controller: controller,
              items: <DebugMenuItem>[_tile('Ping')],
              child: child!,
            ),
        home: const Scaffold(body: Center(child: Text('app'))),
      ),
    );

    controller.open();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Ping'), findsOneWidget);
  });

  testWidgets('実行時の登録は無関係なリビルドを生き延びる', (WidgetTester tester) async {
    // `items` はインラインのリストリテラル — リビルドごとに別インスタンスになる —
    // なので、これでレジストリを作り直して登録済みのものを捨ててはならない。
    final controller = DebugMenuController(isOpen: true);
    addTearDown(controller.dispose);
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            rebuild = setState;
            return DebugMenuHost(
              controller: controller,
              items: <DebugMenuItem>[_tile('Static')],
              child: const Scaffold(body: Center(child: Text('app'))),
            );
          },
        ),
      ),
    );

    DebugMenuScope.of(
      tester.element(find.text('Static')),
    ).registry.register(_tile('Late'));
    await tester.pump();

    expect(find.text('Late'), findsOneWidget);

    rebuild(() {});
    await tester.pump();

    expect(find.text('Late'), findsOneWidget);
    expect(find.text('Static'), findsOneWidget);
  });

  testWidgets('マウント後の items 変更は無音ではなく報告される', (WidgetTester tester) async {
    final controller = DebugMenuController(isOpen: true);
    addTearDown(controller.dispose);
    late StateSetter rebuild;
    var title = 'First';
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            rebuild = setState;
            return DebugMenuHost(
              controller: controller,
              items: <DebugMenuItem>[_tile(title)],
              child: const Scaffold(body: Center(child: Text('app'))),
            );
          },
        ),
      ),
    );

    rebuild(() => title = 'Second');
    await tester.pump();

    expect(tester.takeException(), isA<FlutterError>());
    // 変更は実際に無視される。一覧はマウント時のものを表示したままになる。
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
  });
}
