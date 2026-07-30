import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/posts_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Future<void> _handleSubmit() async {
    final authorId = context.read<AuthProvider>().currentUser?.id;
    if (authorId == null) return;

    final success = await context.read<PostsProvider>().createPost(
          authorId: authorId,
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
      appBar: AppBar(title: const Text('Create Post')),
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