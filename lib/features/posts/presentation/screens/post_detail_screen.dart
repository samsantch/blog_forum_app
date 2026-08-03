import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/posts_provider.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../../comments/presentation/widgets/comment_section.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadPostById(postId: widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();
    final currentUserId = context.watch<AuthProvider>().currentUser?.id;

    if (postsProvider.isLoadingSelectedPost) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final post = postsProvider.selectedPost;
    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: AppStateMessage(
          icon: Icons.error_outline,
          message: postsProvider.selectedPostError ?? 'Post not found.',
        ),
      );
    }

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
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Post'),
                        content: const Text(
                          'Are you sure you want to delete this post?',
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

                    final success = await context
                        .read<PostsProvider>()
                        .deletePost(postId: post.id);

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post deleted successfully.')),
                      );

                      context.pop();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('by ${post.authorUsername ?? "Unknown"}'),
            const SizedBox(height: 16),
            if (post.images.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.images[index].imageUrl,
                          width: 280,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(post.content),
            const SizedBox(height: 24),
            const Divider(),
            CommentSection(postId: post.id),
          ],
        ),
      ),
    );
  }
}