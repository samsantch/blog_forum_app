import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/comments_provider.dart';
import '../../data/models/comment_model.dart';

class CommentTile extends StatefulWidget {
  final CommentModel comment;
  final bool isAuthor;

  const CommentTile({
    super.key,
    required this.comment,
    required this.isAuthor,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _isEditing = false;
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.comment.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveEdit() async {
    final success = await context.read<CommentsProvider>().updateComment(
          commentId: widget.comment.id,
          content: _editController.text.trim(),
        );
    if (success && mounted) {
      setState(() => _isEditing = false);
    }
  }

  Future<void> _handleDelete() async {
    await context.read<CommentsProvider>().deleteComment(
          commentId: widget.comment.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.comment.authorUsername ?? 'Unknown'),
      subtitle: _isEditing
          ? TextField(controller: _editController, autofocus: true)
          : Text(widget.comment.content),
      trailing: !widget.isAuthor
          ? null
          : _isEditing
              ? IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _handleSaveEdit,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => setState(() => _isEditing = true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: _handleDelete,
                    ),
                  ],
                ),
    );
  }
}