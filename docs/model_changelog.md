# 本文档主要记录 models 下对比 `flutter-quill` 已修改的文件内容

## lib/models/documents/nodes/embed.dart

[embed.dart](../lib/models/documents/nodes/embed.dart) 文件改动较多，建议完全替换。

具体修改内容如下：

1. 修改 `Embeddable` 的 `toJson` 和 `fromJson` 方法，以兼容历史数据格式。
2. 在 `Embeddable` 追加 `toFormalJson` 方法，以输出符合规范的正确数据格式。
3. 追加预置数据类型 `ImageEmbed`, `VideoEmbed` 和 `MentionEmbed`。

## lib/models/documents/attribute.dart

1. 追加 `uniqueKey` getter。
2. 追加新的 Attribute: `at`, `channel` 。
3. `_registry` 注册新追加的 `at`, `channel`。

```dart
class Attribute {

  /// Wrap [key] with [value] for keys which has multiple status.
  String get uniqueKey {
    if (key == 'header') {
      return '$key$value';
    }
    if (key == 'list') {
      return '$key-$value';
    }
    return key;
  }

  static final Map<String, Attribute> _registry = LinkedHashMap.of({
    Attribute.bold.key: Attribute.bold,
    Attribute.italic.key: Attribute.italic,
    Attribute.underline.key: Attribute.underline,
    Attribute.strikeThrough.key: Attribute.strikeThrough,
    Attribute.font.key: Attribute.font,
    Attribute.size.key: Attribute.size,
    Attribute.link.key: Attribute.link,
    Attribute.color.key: Attribute.color,
    Attribute.background.key: Attribute.background,
    Attribute.placeholder.key: Attribute.placeholder,
    Attribute.header.key: Attribute.header,
    Attribute.align.key: Attribute.align,
    Attribute.list.key: Attribute.list,
    Attribute.codeBlock.key: Attribute.codeBlock,
    Attribute.blockQuote.key: Attribute.blockQuote,
    Attribute.indent.key: Attribute.indent,
    Attribute.width.key: Attribute.width,
    Attribute.height.key: Attribute.height,
    Attribute.style.key: Attribute.style,
    Attribute.token.key: Attribute.token,
    Attribute.at.key: Attribute.at,
    Attribute.channel.key: Attribute.channel,
  });

  static final AtAttribute at = AtAttribute('');

  static final ChannelAttribute channel = ChannelAttribute('');

}

class AtAttribute extends Attribute<String> {
  AtAttribute(String val) : super('at', AttributeScope.INLINE, val);
}

class ChannelAttribute extends Attribute<String> {
  ChannelAttribute(String val) : super('channel', AttributeScope.INLINE, val);
}
```

## lib/models/quill_delta.dart

1. 修改 `Operation` 的 `fromJson` 方法。
1. 修改 `Operation` 的 `toJson` 方法。
2. 修改 `Operation` 追加 `toFormalJson` 方法。
3. 修改 `Operation` 的 `operator ==` 方法。
4. 修改 `Delta` 追加 `toFormalJson` 方法。

```dart
class Operation {

  /// Creates new [Operation] from JSON payload.
  ///
  /// If `dataDecoder` parameter is not null then it is used to additionally
  /// decode the operation's data object. Only applied to insert operations.
  static Operation fromJson(Map data, {DataDecoder? dataDecoder}) {
    dataDecoder ??= _passThroughDataDecoder;
    final map = Map<String, dynamic>.from(data);
    if (map.containsKey(Operation.insertKey)) {
      final data = dataDecoder(map[Operation.insertKey]);

      final Map<String, dynamic>? attributes = map[Operation.attributesKey] == null
          ? null : Map.from(map[Operation.attributesKey]);
      if (attributes?.containsKey('at') == true) {
        final mentionValue = data is String ? data : '';
        final embed = MentionEmbed.fromAttribute(attributes!['at'], '@', mentionValue);
        return Operation._(Operation.insertKey, 1, embed.toFormalJson(), attributes);
      }
      if (attributes?.containsKey('channel') == true) {
        final mentionValue = data is String ? data : '';
        final embed = MentionEmbed.fromAttribute(attributes!['channel'], '#', mentionValue);
        return Operation._(Operation.insertKey, 1, embed.toFormalJson(), attributes);
      }

      final dataLength = data is String ? data.length : 1;
      return Operation._(
          Operation.insertKey, dataLength, data, map[Operation.attributesKey]);
    } else if (map.containsKey(Operation.deleteKey)) {
      final int? length = map[Operation.deleteKey];
      return Operation._(Operation.deleteKey, length, '', null);
    } else if (map.containsKey(Operation.retainKey)) {
      final int? length = map[Operation.retainKey];
      return Operation._(
          Operation.retainKey, length, '', map[Operation.attributesKey]);
    }
    throw ArgumentError.value(data, 'Invalid data for Delta operation.');
  }

  /// Returns JSON-serializable representation of this operation.
  Map<String, dynamic> toJson() {
    final json = {key: value};
    if (_attributes != null) json[Operation.attributesKey] = attributes;

    if (key == Operation.insertKey) {
      // Embeddable.
      if (value is Map) {
        final embed = Embeddable.fromJson(value);
        if (embed.type == 'mention' && embed is MentionEmbed) {
          json[key] = embed.value;
          Map<String, dynamic> attrMap = attributes != null
              ? Map.from(attributes!) : {};
          attrMap[embed.attributeKey] = embed.id;
          json[Operation.attributesKey] = attrMap;
        } else {
          json[key] = Embeddable.fromJson(value).toJson();
        }
      } else {
        // Check if data is mention embed.
        if (attributes != null && attributes!.containsKey('at')) {
          final mentionId = attributes!['at'] is String ? attributes!['at'] as String : '';
          final mentionValue = value is String ? value as String : '';
          final embed = MentionEmbed.fromAttribute(mentionId, '@', mentionValue);
          json[key] = embed.value;

          Map<String, dynamic> attrMap = attributes != null
              ? Map.from(attributes!) : {};
          attrMap[embed.attributeKey] = embed.id;
          json[Operation.attributesKey] = attrMap;
        }
        if (attributes != null && attributes!.containsKey('channel')) {
          final mentionId = attributes!['channel'] is String ? attributes!['channel'] as String : '';
          final mentionValue = value is String ? value as String : '';
          final embed = MentionEmbed.fromAttribute(mentionId, '#', mentionValue);
          json[key] = embed.value;

          Map<String, dynamic> attrMap = attributes != null
              ? Map.from(attributes!) : {};
          attrMap[embed.attributeKey] = embed.id;
          json[Operation.attributesKey] = attrMap;
        }
      }
    }
    return json;
  }

  /// Returns JSON-serializable representation of this operation.
  Map<String, dynamic> toFormalJson() {
    final json = {key: value};
    if (_attributes != null) json[Operation.attributesKey] = attributes;
    if (key == Operation.insertKey && value is Map) {
      // Embeddable.
      if (value is Map) {
        json[key] = Embeddable.fromJson(value).toFormalJson();
      } else {
        // Check if data is mention embed.
        if (attributes != null && attributes!.containsKey('at')) {
          final mentionId = attributes!['at'] is String ? attributes!['at'] as String : '';
          final mentionValue = value is String ? value as String : '';
          final embed = MentionEmbed.fromAttribute(mentionId, '@', mentionValue);
          json[key] = embed.toFormalJson();
        }
        if (attributes != null && attributes!.containsKey('channel')) {
          final mentionId = attributes!['channel'] is String ? attributes!['channel'] as String : '';
          final mentionValue = value is String ? value as String : '';
          final embed = MentionEmbed.fromAttribute(mentionId, '#', mentionValue);
          json[key] = embed.toFormalJson();
        }
      }
    }
    return json;
  }

}

class Delta {

  /// Returns JSON-serializable version of this delta.
  List toFormalJson() => toList().map((operation) => operation.toFormalJson()).toList();

}
```

## lib/models/documents/document.dart

1. 修改 `Document` 追加 `refreshDocument` 方法。

```dart
class Document {

  void refreshDocument(Delta change, Delta oldDelta, ChangeSource changeSource) {
    _root.children.clear();
    _delta = oldDelta.compose(change);
    _loadDocument(_delta);
    final onChange = Tuple3(oldDelta, change, changeSource);
    _observer.add(onChange);
  }

}
```
