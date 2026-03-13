enum AttachmentType { image, video, audio, file, location, contact }

class ChatAttachment {

  ChatAttachment({
    required this.id,
    required this.type,
    required this.name,
    required this.path,
    this.thumbnail,
    required this.size,
    this.duration,
    required this.createdAt,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'],
      type: AttachmentType.values[json['type']],
      name: json['name'],
      path: json['path'],
      thumbnail: json['thumbnail'],
      size: json['size'],
      duration: json['duration'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  final String id;
  final AttachmentType type;
  final String name;
  final String path;
  final String? thumbnail;
  final int size;
  final double? duration;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.index,
    'name': name,
    'path': path,
    'thumbnail': thumbnail,
    'size': size,
    'duration': duration,
    'createdAt': createdAt.toIso8601String(),
  };
}