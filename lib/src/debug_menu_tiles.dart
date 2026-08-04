import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// デバッグメニュー用の読み取り専用の `label: value` 行。タップでコピーできる。
///
/// あくまで便宜的なもの。メニュー項目には任意のウィジェットを使えるので、
/// これで足りない場合は素の `ListTile` や `ExpansionTile` を使えばよい。
class DebugMenuInfoTile extends StatelessWidget {
  /// 情報タイルを生成する。
  const DebugMenuInfoTile({
    required this.label,
    required this.value,
    this.copyable = true,
    super.key,
  });

  /// この値が何であるかを表すラベル。
  final String label;

  /// 値そのもの。[label] の下に表示される。
  final String value;

  /// タップしたときに [value] をクリップボードへコピーするかどうか。
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      subtitle: Text(value),
      trailing: copyable ? const Icon(Icons.copy, size: 16) : null,
      onTap:
          copyable ? () => Clipboard.setData(ClipboardData(text: value)) : null,
    );
  }
}
