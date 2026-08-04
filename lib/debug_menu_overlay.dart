/// 複数本指のタップで開くアプリ内デバッグメニュー。
///
/// メニューはアプリの上に描画され、専用の [Navigator] を内部に持つ。そのため
/// デバッグ用のサブページを push しても、アプリのルーター・ルートオブザーバー・
/// 画面表示アナリティクスには一切現れない。
///
/// ```dart
/// DebugMenuHost(
///   enabled: !kReleaseMode,
///   items: [
///     DebugMenuItem(
///       title: 'Version',
///       builder: (context, scope) => const DebugMenuInfoTile(
///         label: 'Version',
///         value: '1.0.0+1',
///       ),
///     ),
///   ],
///   child: const MyApp(),
/// );
/// ```
library;

export 'src/debug_menu_activation.dart';
export 'src/debug_menu_controller.dart';
export 'src/debug_menu_host.dart';
export 'src/debug_menu_item.dart';
export 'src/debug_menu_registry.dart';
export 'src/debug_menu_scope.dart' show DebugMenuScope;
export 'src/debug_menu_theme.dart';
export 'src/debug_menu_tiles.dart';
