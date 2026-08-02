import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../data/comment_repository.dart';
import '../data/models/comment_model.dart';
import '../../../core/services/storage_service.dart';

class CommentsProvider extends ChangeNotifier {
  final CommentRepository _commentRepository = CommentRepository();
  final StorageService _storageService = StorageService();

  List<CommentModel> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadComments({required String postId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _commentRepository.getCommentsForPost(postId: postId);
    } catch (e) {
      _errorMessage = 'Failed to load comments.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComment({
    required String postId,
    required String authorId,
    required String content,
    List<XFile> images = const [],
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComment = await _commentRepository.createComment(
        postId: postId,
        authorId: authorId,
        content: content,
      );

      for (final image in images) {
        final fileBytes = await image.readAsBytes();
        final fileExtension = image.path.split('.').last;
        final path =
            '${newComment.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

        final imageUrl = await _storageService.uploadFile(
          bucket: 'comment-images',
          path: path,
          fileBytes: fileBytes,
          contentType: 'image/$fileExtension',
        );

        await _commentRepository.addCommentImage(
          commentId: newComment.id,
          imageUrl: imageUrl,
        );
      }

      final fullComment = images.isEmpty
          ? newComment
          : await _commentRepository.getCommentById(commentId: newComment.id);

      _comments.add(fullComment);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add comment.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateComment({
    required String commentId,
    required String content,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComment = await _commentRepository.updateComment(
        commentId: commentId,
        content: content,
      );
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = updatedComment;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update comment.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteComment({required String commentId}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _commentRepository.deleteComment(commentId: commentId);
      _comments.removeWhere((c) => c.id == commentId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete comment.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCommentImage({
    required String commentId,
    required String imageId,
  }) async {
    try {
      await _commentRepository.deleteCommentImage(imageId: imageId);
      final updatedComment =
          await _commentRepository.getCommentById(commentId: commentId);
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = updatedComment;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete image.';
      notifyListeners();
      return false;
    }
  }
}