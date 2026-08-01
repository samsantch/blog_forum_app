class PostImageModel {
  final String id;
  final String postId;
  final String imageUrl;

  PostImageModel({
    required this.id,
    required this.postId,
    required this.imageUrl,
  });

  factory PostImageModel.fromMap(Map<String, dynamic> map) {
    return PostImageModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      imageUrl: map['image_url'] as String,
    );
  }
}