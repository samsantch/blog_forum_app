import 'package:flutter/foundation.dart';
import '../data/post_repository.dart';
import '../data/models/post_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage_service.dart';


class PostsProvider extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final StorageService _storageService = StorageService();


  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final firstPage =
          await _postRepository.getPosts(page: 0, pageSize: _pageSize);
      _posts = firstPage;
      _hasMore = firstPage.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Failed to load posts.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final nextPage = await _postRepository.getPosts(
        page: _currentPage,
        pageSize: _pageSize,
      );
      _posts.addAll(nextPage);
      _hasMore = nextPage.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Failed to load more posts.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String authorId,
    required String title,
    required String content,
    List<XFile> images = const [],
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

      for (final image in images) {
        final fileBytes = await image.readAsBytes();
        final fileExtension = image.path.split('.').last;
        final path =
            '${newPost.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        final imageUrl = await _storageService.uploadFile(
          bucket: 'post-images',
          path: path,
          fileBytes: fileBytes,
          contentType: 'image/$fileExtension',
        );

        await _postRepository.addPostImage(
          postId: newPost.id,
          imageUrl: imageUrl,
        );
      }

      final fullPost = await _postRepository.getPostById(postId: newPost.id);
      _posts.insert(0, fullPost);
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