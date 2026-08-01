import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/comment_model.dart';

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

  Future<List<CommentModel>> getCommentsForPost({required String postId}) async {
    final response = await _supabaseClient
        .from('comments')
        .select('*, profiles(username, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((map) => CommentModel.fromMap(map))
        .toList();
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
        .select('*, profiles(username, avatar_url)')
        .single();

    return CommentModel.fromMap(response);
  }

  Future<void> deleteComment({required String commentId}) async {
    await _supabaseClient.from('comments').delete().eq('id', commentId);
  }
}