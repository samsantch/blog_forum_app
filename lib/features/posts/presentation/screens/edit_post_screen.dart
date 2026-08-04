import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/posts_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  List<XFile> _newImages = [];
  final Set<String> _imagesToDelete = {};

  @override
  void initState() {
    super.initState();
    final post = context
        .read<PostsProvider>()
        .posts
        .firstWhere((p) => p.id == widget.postId,
            orElse: () => context.read<PostsProvider>().selectedPost!);

    _titleController = TextEditingController(text: post.title);
    _contentController = TextEditingController(text: post.content);
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() => _newImages = pickedFiles);
    }
  }

  void _toggleImageForDeletion(String imageId) {
    setState(() {
      if (_imagesToDelete.contains(imageId)) {
        _imagesToDelete.remove(imageId);
      } else {
        _imagesToDelete.add(imageId);
      }
    });
  }

  Future<void> _handleSave() async {
    final postsProvider = context.read<PostsProvider>();

    final success = await postsProvider.updatePost(
      postId: widget.postId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );
    if (!success) return;

    for (final imageId in _imagesToDelete) {
      await postsProvider.deletePostImage(
        postId: widget.postId,
        imageId: imageId,
      );
    }

    if (_newImages.isNotEmpty) {
      await postsProvider.addImagesToPost(
        postId: widget.postId,
        images: _newImages,
      );
    }

    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();
    final post = postsProvider.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => postsProvider.selectedPost!,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(controller: _titleController, label: 'Title'),
            const SizedBox(height: 12),
            AppTextField(controller: _contentController, label: 'Content'),
            const SizedBox(height: 16),

            if (post.images.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Existing images',
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tap × to mark for removal. Changes only apply after Save.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    final image = post.images[index];
                    final marked = _imagesToDelete.contains(image.id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Opacity(
                            opacity: marked ? 0.3 : 1.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                image.imageUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _toggleImageForDeletion(image.id),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  marked ? Icons.undo : Icons.close,
                                  size: 14,
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
              const SizedBox(height: 16),
            ],

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Images'),
              ),
            ),
            if (_newImages.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FutureBuilder<Uint8List>(
                        future: _newImages[index].readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 90,
                              height: 90,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              snapshot.data!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
            if (postsProvider.errorMessage != null)
              Text(postsProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            AppButton(
              label: 'Save',
              isLoading: postsProvider.isSubmitting,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}