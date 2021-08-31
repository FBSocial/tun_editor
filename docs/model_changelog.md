# 本文档主要记录 models 下对比 `flutter-quill` 已修改的文件内容

## lib/models/documents/nodes/embed.dart

[embed.dart](../lib/models/documents/nodes/embed.dart) 文件改动较多，建议完全替换。

具体修改内容如下：

1. 修改 `Embeddable` 的 `toJson` 和 `fromJson` 方法，以兼容历史数据格式。
2. 在 `Embeddable` 追加 `toFormalJson` 方法，以输出符合规范的正确数据格式。
3. 追加预置数据类型 `ImageEmbed`, `VideoEmbed` 和 `MentionEmbed`。

## lib/models/documents/attribute.dart

1. 追加 `uniqueKey` getter。

```dart
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
```

## lib/models/quill_delta.dart

1. 修改 `Operation` 的 `toJson` 方法。
2. 修改 `Operation` 追加 `toFormalJson` 方法。
3. 修改 `Operation` 的 `operator ==` 方法。
4. 修改 `Delta` 追加 `toFormalJson` 方法。

```dart
class Operation {

  /// Returns JSON-serializable representation of this operation.
  Map<String, dynamic> toJson() {
    final json = {key: value};
    if (_attributes != null) json[Operation.attributesKey] = attributes;
    // Embeddable.
    if (key == Operation.insertKey && value is Map) {
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
    }
    return json;
  }

  /// Returns JSON-serializable representation of this operation.
  Map<String, dynamic> toFormalJson() {
    final json = {key: value};
    if (_attributes != null) json[Operation.attributesKey] = attributes;
    // Embeddable.
    if (key == Operation.insertKey && value is Map) {
      json[key] = Embeddable.fromJson(value).toFormalJson();
    }
    return json;
  }

}

class Delta {

  /// Returns JSON-serializable version of this delta.
  List toFormalJson() => toList().map((operation) => operation.toFormalJson()).toList();

}
```
