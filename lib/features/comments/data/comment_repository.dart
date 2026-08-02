import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/comment_model.dart';
import 'models/comment_image_model.dart';

class CommentRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<CommentModel> createComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    final response = await _supabaseClient
        .from('comments')
        .insert({
          'post_id': postId,
          'author_id': authorId,
          'content': content,
        })
        .select('*, profiles(username, avatar_url)')
        .single();

    return CommentModel.fromMap(response);
  }

  Future<List<CommentModel>> getCommentsForPost({
    required String postId,
  }) async {
    final response = await _supabaseClient
        .from('comments')
        .select(
            '*, profiles(username, avatar_url), comment_images(id, comment_id, image_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((map) => CommentModel.fromMap(map))
        .toList();
  }

  Future<CommentModel> getCommentById({required String commentId}) async {
    final response = await _supabaseClient
        .from('comments')
        .select(
            '*, profiles(username, avatar_url), comment_images(id, comment_id, image_url)')
        .eq('id', commentId)
        .single();

    return CommentModel.fromMap(response);
  }

  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  }) async {
    final response = await _supabaseClient
        .from('comments')
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', commentId)
        .select(
            '*, profiles(username, avatar_url), comment_images(id, comment_id, image_url)')
        .single();

    return CommentModel.fromMap(response);
  }

  Future<void> deleteComment({required String commentId}) async {
    await _supabaseClient.from('comments').delete().eq('id', commentId);
  }

  Future<CommentImageModel> addCommentImage({
    required String commentId,
    required String imageUrl,
  }) async {
    final response = await _supabaseClient
        .from('comment_images')
        .insert({
          'comment_id': commentId,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return CommentImageModel.fromMap(response);
  }

  Future<void> deleteCommentImage({required String imageId}) async {
    await _supabaseClient.from('comment_images').delete().eq('id', imageId);
  }
}