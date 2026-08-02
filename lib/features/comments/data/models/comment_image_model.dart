class CommentImageModel {
  final String id;
  final String commentId;
  final String imageUrl;

  CommentImageModel({
    required this.id,
    required this.commentId,
    required this.imageUrl,
  });

  factory CommentImageModel.fromMap(Map<String, dynamic> map) {
    return CommentImageModel(
      id: map['id'] as String,
      commentId: map['comment_id'] as String,
      imageUrl: map['image_url'] as String,
    );
  }
}