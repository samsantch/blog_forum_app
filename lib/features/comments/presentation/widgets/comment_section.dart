import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/comments_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import 'comment_tile.dart';
import '../../../../core/widgets/app_state_message.dart';
import 'package:go_router/go_router.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentsProvider>().loadComments(postId: widget.postId);
    });
  }

  Future<void> _handlePostComment() async {
    final authorId = context.read<AuthProvider>().currentUser?.id;
    if (authorId == null) return;
    if (_commentController.text.trim().isEmpty) return;

    final success = await context.read<CommentsProvider>().createComment(
          postId: widget.postId,
          authorId: authorId,
          content: _commentController.text.trim(),
        );

    if (success) {
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsProvider = context.watch<CommentsProvider>();
    final currentUserId = context.watch<AuthProvider>().currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        currentUserId == null
            ? TextButton(
                onPressed: () => context.push('/login'),
                child: const Text('Log in to comment'),
              )
            : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration:
                          const InputDecoration(hintText: 'Add a comment...'),
                    ),
                  ),
                  IconButton(
                    icon: commentsProvider.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: commentsProvider.isSubmitting
                        ? null
                        : _handlePostComment,
                  ),
                ],
              ),
        const SizedBox(height: 8),
        if (commentsProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (commentsProvider.errorMessage != null)
          AppStateMessage(
            icon: Icons.error_outline,
            message: commentsProvider.errorMessage!,
            actionLabel: 'Retry',
            onAction: () => context
                .read<CommentsProvider>()
                .loadComments(postId: widget.postId),
          )
        else if (commentsProvider.comments.isEmpty)
          const AppStateMessage(
            icon: Icons.chat_bubble_outline,
            message: 'No comments yet. Start the conversation!',
          )
        else
          Column(
            children: commentsProvider.comments.map((comment) {
              return CommentTile(
                comment: comment,
                isAuthor: comment.authorId == currentUserId,
              );
            }).toList(),
          ),
      ],
    );
  }
}