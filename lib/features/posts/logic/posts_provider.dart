import 'package:flutter/foundation.dart';
import '../data/post_repository.dart';
import '../data/models/post_model.dart';

class PostsProvider extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();

  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _postRepository.getPosts();
    } catch (e) {
      _errorMessage = 'Failed to load posts.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String authorId,
    required String title,
    required String content,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPost = await _postRepository.createPost(
        authorId: authorId,
        title: title,
        content: content,
      );
      _posts.insert(0, newPost);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create post.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost({
    required String postId,
    String? title,
    String? content,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postRepository.updatePost(
        postId: postId,
        title: title,
        content: content,
      );

      final updatedPost = await _postRepository.getPostById(postId: postId);
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update post.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost({required String postId}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postRepository.deletePost(postId: postId);
      _posts.removeWhere((post) => post.id == postId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete post.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}