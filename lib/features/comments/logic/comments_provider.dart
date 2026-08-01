import 'package:flutter/foundation.dart';
import '../data/comment_repository.dart';
import '../data/models/comment_model.dart';

class CommentsProvider extends ChangeNotifier {
  final CommentRepository _commentRepository = CommentRepository();

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
      _comments.add(newComment);
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
}