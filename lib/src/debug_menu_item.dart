import 'package:flutter/widgets.dart';

import 'debug_menu_scope.dart';

/// [DebugMenuItem] がデバッグメニューの一覧に表示するウィジェットを構築する。
///
/// [context] はデバッグウィンドウ専用の [Navigator] の内側にある。そのため項目から
/// `Navigator.of(context).push(...)` を呼べば、アプリのルーターに触れずにサブページを
/// 開ける。
typedef DebugMenuItemBuilder =
    Widget Function(BuildContext context, DebugMenuScope scope);

/// デバッグメニューの 1 項目。
///
/// 項目は単なるウィジェットでよい。`ListTile`、`ExpansionTile`、複数行の `Column` —
/// `ListView` に入れられるものなら何でも使える。実装すべきプラグイン
/// インターフェースのようなものは存在しない。
@immutable
class DebugMenuItem {
  /// 項目を生成する。
  const DebugMenuItem({
    required this.title,
    required this.builder,
    this.id,
    this.visibleWhen,
  });

  /// この項目の名前。
  ///
  /// タイトルはメタデータである。一覧に表示されるのは [builder] が返したものなので、
  /// ユーザーに見えるラベルは構築したウィジェットの中にも入れておくこと。
  final String title;

  /// 任意の安定した識別子。`DebugMenuRegistry.register` での置き換えと
  /// `DebugMenuRegistry.unregister` での削除に使われる。
  final String? id;

  /// 一覧に表示するウィジェットを構築する。
  final DebugMenuItemBuilder builder;

  /// 一覧が構築されるたびに評価される。false を返すとその項目は隠れる。
  ///
  /// 特定のプラットフォームや特定の画面でのみ出したい項目に使う。たとえば
  /// `visibleWhen: () => Platform.isAndroid` のように書く。
  final bool Function()? visibleWhen;

  /// この項目を今一覧に出すべきかどうか。
  bool get isVisible => visibleWhen?.call() ?? true;
}
