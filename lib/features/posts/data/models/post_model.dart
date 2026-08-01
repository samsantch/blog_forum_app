import 'post_image_model.dart';

class PostModel {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorUsername;
  final List<PostImageModel> images;

  PostModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.authorUsername,
    this.images = const [],
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      authorId: map['author_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      authorUsername: map['profiles'] != null
          ? map['profiles']['username'] as String?
          : null,
      images: map['post_images'] != null
          ? (map['post_images'] as List)
              .map((img) => PostImageModel.fromMap(img))
              .toList()
          : [],
    );
  }
}