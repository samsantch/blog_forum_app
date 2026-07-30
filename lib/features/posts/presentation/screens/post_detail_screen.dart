import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/posts_provider.dart';
import '../../data/models/post_model.dart';
import '../../../auth/logic/auth_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();
    final currentUserId = context.watch<AuthProvider>().currentUser?.id;

    final PostModel post = postsProvider.posts.firstWhere(
      (p) => p.id == widget.postId,
    );

    final isAuthor = post.authorId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: isAuthor
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/posts/${post.id}/edit'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final success = await context
                        .read<PostsProvider>()
                        .deletePost(postId: post.id);
                    if (success && context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('by ${post.authorUsername ?? "Unknown"}'),
            const SizedBox(height: 16),
            Text(post.content),
          ],
        ),
      ),
    );
  }
}