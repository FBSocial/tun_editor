/// An object which can be embedded into a Quill document.
///
/// See also:
///
/// * [BlockEmbed] which represents a block embed.
class Embeddable {
  const Embeddable(this.type, this.data);

  /// The type of this object.
  final String type;

  /// The data payload of this object.
  final dynamic data;

  Map<String, dynamic> toJson() {
    if (type == 'image' || type == 'video') {
      return data;
    }
    return toFormalJson();
  }

  Map<String, dynamic> toFormalJson() {
    final m = <String, dynamic>{type: data};
    return m;
  }

  static Embeddable fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    assert(m.length > 0, 'Embeddable can not be empty');
    if (m.length > 1 && m.containsKey('_type')) {
      final type = m['_type'];
      if (type == 'image') {
        return ImageEmbed.fromJson(m);
      }
      if (type == 'video') {
        return VideoEmbed.fromJson(m);
      }
    }
    if (m.containsKey('image')) {
      return ImageEmbed.fromJson(m['image']);
    }
    if (m.containsKey('video')) {
      return VideoEmbed.fromJson(m['video']);
    }
    if (m.containsKey('mention')) {
      return MentionEmbed.fromJson(m['mention']);
    }
    return BlockEmbed(m.keys.first, m.values.first);
  }
}

/// An object which occupies an entire line in a document and cannot co-exist
/// inline with regular text.
///
/// There are two built-in embed types supported by Quill documents, however
/// the document model itself does not make any assumptions about the types
/// of embedded objects and allows users to define their own types.
class BlockEmbed extends Embeddable {
  const BlockEmbed(String type, dynamic data) : super(type, data);

  static const String horizontalRuleType = 'divider';
  static BlockEmbed horizontalRule = const BlockEmbed(horizontalRuleType, 'hr');

  static const String imageType = 'image';
  static BlockEmbed image(String imageUrl) => BlockEmbed(imageType, imageUrl);

  static const String videoType = 'video';
  static BlockEmbed video(String videoUrl) => BlockEmbed(videoType, videoUrl);
}

class ImageEmbed extends Embeddable {
  final String? name;
  final String? checkPath;
  final String source;
  final num width;
  final num height;
  ImageEmbed({
    this.name,
    this.checkPath,
    required this.source,
    required this.width,
    required this.height,
  }) : super('image', {
          'name': name,
          'source': source,
          'width': width,
          'height': height,
          'checkPath': checkPath,
          '_type': 'image',
          '_inline': false,
        });
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'source': source,
      'width': width,
      'height': height,
      'checkPath': checkPath,
      '_type': 'image',
      '_inline': false,
    };
  }
  @override
  Map<String, dynamic> toFormalJson() {
    final res = <String, dynamic>{
      'image': toJson(),
    };
    return res;
  }

  static ImageEmbed fromJson(Map<String, dynamic> data) {
    num width = 0;
    if (data['width'] is String) {
      width = num.tryParse(data['width']) ?? 0;
    } else if (data['width'] is num) {
      width = data['width'];
    }
    num height = 0;
    if (data['height'] is String) {
      height = num.tryParse(data['height']) ?? 0;
    } else if (data['height'] is num) {
      height = data['height'];
    }
    return ImageEmbed(
      name: data['name'] as String,
      source: data['source'] as String,
      checkPath: data['checkPath'] as String?,
      width: width,
      height: height,
    );
  }
}

class VideoEmbed extends Embeddable {
  final num width;
  final num height;
  final String source;
  final String fileType;
  final num duration;
  final String thumbUrl;
  final String? thumbName;
  VideoEmbed({
    required this.width,
    required this.height,
    required this.source,
    required this.fileType,
    required this.duration,
    required this.thumbUrl,
    this.thumbName,
  }) : super('video', {
          'width': width,
          'height': height,
          'source': source,
          'fileType': fileType,
          'duration': duration,
          'thumbUrl': thumbUrl,
          'thumbName': thumbName,
          '_type': 'video',
          '_inline': false,
        });
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'source': source,
      'fileType': fileType,
      'duration': duration,
      'thumbUrl': thumbUrl,
      'thumbName': thumbName,
      '_type': 'video',
      '_inline': false,
    };
  }
  @override
  Map<String, dynamic> toFormalJson() {
    return <String, dynamic>{
      'video': toJson(),
    };
  }

  static VideoEmbed fromJson(Map<String, dynamic> data) {
    num width = 0;
    if (data['width'] is String) {
      width = num.tryParse(data['width']) ?? 0;
    } else if (data['width'] is num) {
      width = data['width'];
    }
    num height = 0;
    if (data['height'] is String) {
      height = num.tryParse(data['height']) ?? 0;
    } else if (data['height'] is num) {
      height = data['height'];
    }
    num duration = 0;
    if (data['duration'] is String) {
      duration = num.tryParse(data['duration']) ?? 0;
    } else if (data['duration'] is num) {
      duration = data['duration'];
    }
    return VideoEmbed(
      width: width,
      height: height,
      source: data['source'],
      fileType: data['fileType'],
      duration: duration,
      thumbUrl: data['thumbUrl'],
      thumbName: data['thumbName'],
    );
  }
}

class MentionEmbed extends Embeddable {

  String denotationChar;
  String id;
  String value;
  String prefixChar;

  String get attributeKey {
    switch (prefixChar) {
      case '@':
        return 'at';
      case 'at':
        return 'at';
      case 'channel':
        return 'channel';
      case '#':
        return 'channel';
      default:
        return 'at';
    }
  }

  MentionEmbed({
    required this.denotationChar,
    required this.id,
    required this.value,
    required this.prefixChar,
  }) : super('mention', {
    'denotationChar': denotationChar,
    'id': id,
    'value': value,
    'prefixChar': prefixChar,
  });

  @override
  Map<String, dynamic> toFormalJson() {
    return <String, dynamic>{
      'mention': {
        'denotationChar': denotationChar,
        'id': id,
        'value': value,
        'prefixChar': prefixChar,
      },
    };
  }

  static MentionEmbed fromJson(Map<String, dynamic> data) {
    return MentionEmbed(
      denotationChar: data['denotationChar'],
      id: data['id'],
      value: data['value'],
      prefixChar: data['prefixChar'],
    );
  }

  static MentionEmbed fromAttribute(String id, String prefixChar, String value) {
    return MentionEmbed(
      denotationChar: '',
      id: id,
      value: value,
      prefixChar: prefixChar,
    );
  }

}
