// スモークテスト。example アプリが起動し、アプリ自身のボタンでデバッグメニューが
// 開くことを確認する。
import 'package:debug_menu_overlay_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('アプリが起動し、デバッグメニューを開ける', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('debug_menu_overlay'), findsOneWidget);
    expect(find.text('Example debug menu'), findsNothing);

    await tester.tap(find.text('Open it from the app'));
    await tester.pumpAndSettle();

    expect(find.text('Example debug menu'), findsOneWidget);
    expect(find.text('Version'), findsWidgets);
  });
}
