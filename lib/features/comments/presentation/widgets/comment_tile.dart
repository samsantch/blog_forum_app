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
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text(
          'Are you sure you want to delete this comment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final success = await context.read<CommentsProvider>().deleteComment(
          commentId: widget.comment.id,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment deleted.'),
        ),
      );
    }
  }

  Future<void> _handleDeleteImage(String imageId) async {
    await context.read<CommentsProvider>().deleteCommentImage(
          commentId: widget.comment.id,
          imageId: imageId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.comment.authorUsername ?? 'Unknown'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isEditing
              ? TextField(controller: _editController, autofocus: true)
              : Text(widget.comment.content),
          if (widget.comment.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.comment.images.length,
                  itemBuilder: (context, index) {
                    final image = widget.comment.images[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              image.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (widget.isAuthor && _isEditing)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _handleDeleteImage(image.id),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      trailing: !widget.isAuthor
          ? null
          : _isEditing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _editController.text = widget.comment.content;
                          _isEditing = false;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, size: 18),
                      onPressed: _handleSaveEdit,
                    ),
                  ],
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