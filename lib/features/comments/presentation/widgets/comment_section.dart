import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/comments_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import 'comment_tile.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentsProvider>().loadComments(postId: widget.postId);
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() => _selectedImages = pickedFiles);
    }
  }

  Future<void> _handlePostComment() async {
    final authorId = context.read<AuthProvider>().currentUser?.id;
    if (authorId == null) return;
    if (_commentController.text.trim().isEmpty) return;

    final success = await context.read<CommentsProvider>().createComment(
          postId: widget.postId,
          authorId: authorId,
          content: _commentController.text.trim(),
          images: _selectedImages,
        );

    if (success) {
      _commentController.clear();
      setState(() => _selectedImages = []);
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
                onPressed: () => context.go('/login'),
                child: const Text('Log in to comment'),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FutureBuilder<Uint8List>(
                              future: _selectedImages[index].readAsBytes(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  );
                                }
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.memory(
                                        snapshot.data!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _selectedImages =
                                              List.of(_selectedImages)
                                                ..removeAt(index);
                                        }),
                                        child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.black54,
                                          child: Icon(Icons.close,
                                              size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image_outlined),
                        onPressed: _pickImages,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                              hintText: 'Add a comment...'),
                        ),
                      ),
                      IconButton(
                        icon: commentsProvider.isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        onPressed: commentsProvider.isSubmitting
                            ? null
                            : _handlePostComment,
                      ),
                    ],
                  ),
                ],
              ),
        const SizedBox(height: 8),
        if (commentsProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (commentsProvider.errorMessage != null)
          Text(commentsProvider.errorMessage!)
        else if (commentsProvider.comments.isEmpty)
          const Text('No comments yet. Start the conversation!')
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