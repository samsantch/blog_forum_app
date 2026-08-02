import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/posts_provider.dart';
import '../../data/models/post_model.dart';
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

  @override
  void initState() {
    super.initState();
    final post = context.read<PostsProvider>().selectedPost!;
    _titleController = TextEditingController(text: post.title);
    _contentController = TextEditingController(text: post.content);
  }

  Future<void> _handleSave() async {
    final success = await context.read<PostsProvider>().updatePost(
          postId: widget.postId,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
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
      appBar: AppBar(title: const Text('Edit Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(controller: _titleController, label: 'Title'),
            const SizedBox(height: 12),
            AppTextField(controller: _contentController, label: 'Content'),
            const SizedBox(height: 20),
            if (postsProvider.errorMessage != null)
              Text(
                postsProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
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