import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/post_model.dart';
import 'models/post_image_model.dart';

class PostRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<PostModel> createPost({
    required String authorId,
    required String title,
    required String content,
  }) async {
    final response = await _supabaseClient
        .from('posts')
        .insert({
          'author_id': authorId,
          'title': title,
          'content': content,
        })
        .select()
        .single();

    return PostModel.fromMap(response);
  }

  Future<List<PostModel>> getPosts({
    required int page,
    int pageSize = 10,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await _supabaseClient
        .from('posts')
        .select('*, profiles(username, avatar_url), post_images(id, post_id, image_url)')
        .order('created_at', ascending: false)
        .range(from, to);

    return (response as List)
        .map((map) => PostModel.fromMap(map))
        .toList();
  }

  Future<PostModel> getPostById({required String postId}) async {
    final response = await _supabaseClient
        .from('posts')
        .select('*, profiles(username, avatar_url), post_images(id, post_id, image_url)')
        .eq('id', postId)
        .single();

    return PostModel.fromMap(response);
  }

  Future<void> updatePost({
    required String postId,
    String? title,
    String? content,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;

    await _supabaseClient.from('posts').update(updates).eq('id', postId);
  }

  Future<void> deletePost({required String postId}) async {
    await _supabaseClient.from('posts').delete().eq('id', postId);
  }

  Future<PostImageModel> addPostImage({
    required String postId,
    required String imageUrl,
  }) async {
    final response = await _supabaseClient
        .from('post_images')
        .insert({
          'post_id': postId,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return PostImageModel.fromMap(response);
  }
}