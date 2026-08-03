import 'package:flutter/foundation.dart';
import '../data/post_repository.dart';
import '../data/models/post_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage_service.dart';

class PostsProvider extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final StorageService _storageService = StorageService();

  // --- List State ---
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // --- My Posts State ---
  List<PostModel> _myPosts = [];
  bool _isLoadingMyPosts = false;
  String? _myPostsError;

  // --- Selected Post State ---
  PostModel? _selectedPost;
  bool _isLoadingSelectedPost = false;
  String? _selectedPostError;

  // --- Pagination State ---
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // --- List Getters ---
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // --- My Posts Getters ---
  List<PostModel> get myPosts => _myPosts;
  bool get isLoadingMyPosts => _isLoadingMyPosts;
  String? get myPostsError => _myPostsError;

  // --- Selected Post Getters ---
  PostModel? get selectedPost => _selectedPost;
  bool get isLoadingSelectedPost => _isLoadingSelectedPost;
  String? get selectedPostError => _selectedPostError;

  // --- Pagination Getters ---
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  // ==========================================
  // METHODS
  // ==========================================

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
  
  Future<void> loadMyPosts({required String authorId}) async {
    _isLoadingMyPosts = true;
    _myPostsError = null;
    notifyListeners();

    try {
      _myPosts = await _postRepository.getPostsByAuthor(authorId: authorId);
    } catch (e) {
      _myPostsError = 'Failed to load your posts.';
    } finally {
      _isLoadingMyPosts = false;
      notifyListeners();
    }
  }

  Future<void> loadPostById({required String postId}) async {
    _isLoadingSelectedPost = true;
    _selectedPostError = null;
    notifyListeners();

    try {
      _selectedPost = await _postRepository.getPostById(postId: postId);
    } catch (e) {
      _selectedPostError = 'Failed to load post.';
    } finally {
      _isLoadingSelectedPost = false;
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
        final fileExtension = StorageService.extensionOf(image);
        final path =
            '${newPost.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        final imageUrl = await _storageService.uploadFile(
          bucket: 'post-images',
          path: path,
          fileBytes: fileBytes,
          contentType: StorageService.contentTypeOf(image),
        );

        await _postRepository.addPostImage(
          postId: newPost.id,
          imageUrl: imageUrl,
        );
      }

      final fullPost = await _postRepository.getPostById(postId: newPost.id);
      _posts.insert(0, fullPost);
      _myPosts.insert(0, fullPost);
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
      if (_selectedPost?.id == postId) {
        _selectedPost = updatedPost;
      }

      final myIndex = _myPosts.indexWhere((p) => p.id == postId);
      if (myIndex != -1) {
        _myPosts[myIndex] = updatedPost;
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
      _myPosts.removeWhere((post) => post.id == postId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete post.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deletePostImage({
    required String postId,
    required String imageId,
  }) async {
    try {
      await _postRepository.deletePostImage(imageId: imageId);
      final updatedPost = await _postRepository.getPostById(postId: postId);
      _syncPostEverywhere(updatedPost);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete image.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addImagesToPost({
    required String postId,
    required List<XFile> images,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      for (final image in images) {
        final fileBytes = await image.readAsBytes();
        final fileExtension = StorageService.extensionOf(image);
        final path =
            '$postId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        final imageUrl = await _storageService.uploadFile(
          bucket: 'post-images',
          path: path,
          fileBytes: fileBytes,
          contentType: StorageService.contentTypeOf(image),
        );

        await _postRepository.addPostImage(postId: postId, imageUrl: imageUrl);
      }

      final updatedPost = await _postRepository.getPostById(postId: postId);
      _syncPostEverywhere(updatedPost);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add images.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _syncPostEverywhere(PostModel updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) _posts[index] = updatedPost;

    final myIndex = _myPosts.indexWhere((p) => p.id == updatedPost.id);
    if (myIndex != -1) _myPosts[myIndex] = updatedPost;

    if (_selectedPost?.id == updatedPost.id) _selectedPost = updatedPost;

    notifyListeners();
  }

  Future<void> refreshPosts() async {
    _errorMessage = null;
    _currentPage = 0;
    _hasMore = true;

    try {
      final firstPage =
          await _postRepository.getPosts(page: 0, pageSize: _pageSize);
      _posts = firstPage;
      _hasMore = firstPage.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Failed to refresh posts.';
    } finally {
      notifyListeners();
    }
  }
}