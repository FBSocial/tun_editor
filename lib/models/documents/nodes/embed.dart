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
    final m = <String, dynamic>{type: data};
    return m;
  }

  Map<String, dynamic> toCompatibleJson() {
    if (type == 'image' || type == 'video') {
      return data;
    }
    return toJson();
  }

  static Embeddable fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    // assert(m.length == 1, 'Embeddable map has one key');
    if (m.length > 1 && m.containsKey('_type')) {
      final type = m['_type'];
      if (type == 'image') {
        return ImageEmbed.fromJson(m);
      }
      if (type == 'video') {
        return VideoEmbed.fromJson(m);
      }
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
  Map<String, dynamic> toCompatibleJson() {
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
  static ImageEmbed fromJson(Map<String, dynamic> data) {
    return ImageEmbed(
      name: data['name'] as String,
      source: data['source'] as String,
      checkPath: data['checkPath'] as String,
      width: data['width'] as num,
      height: data['height'] as num,
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
  Map<String, dynamic> toCompatibleJson() {
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

  static VideoEmbed fromJson(Map<String, dynamic> data) {
    return VideoEmbed(
      width: data['width'],
      height: data['height'],
      source: data['source'],
      fileType: data['fileType'],
      duration: data['duration'],
      thumbUrl: data['thumbUrl'],
      thumbName: data['thumbName'],
    );
  }
}
