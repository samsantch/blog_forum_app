import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/posts_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final authorId = context.read<AuthProvider>().currentUser?.id;
    if (authorId == null) return;

    final success = await context.read<PostsProvider>().createPost(
          authorId: authorId,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          images: _selectedImages,
        );

    if (success && mounted) {
      context.pop();
    }
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

    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(controller: _titleController, label: 'Title'),
            const SizedBox(height: 12),
            AppTextField(controller: _contentController, label: 'Content'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Add Images'),
              ),
            ),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FutureBuilder<Uint8List>(
                        future: _selectedImages[index].readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              snapshot.data!,
                              width: 100,
                              height: 100,
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
              Text(
                postsProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Publish',
              isLoading: postsProvider.isSubmitting,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}