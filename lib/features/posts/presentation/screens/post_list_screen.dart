import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/posts_provider.dart';
import '../../../../core/widgets/app_state_message.dart';
import '../../../auth/logic/auth_provider.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadPosts();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostsProvider>().loadMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: postsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : postsProvider.errorMessage != null
              ? AppStateMessage(
                  icon: Icons.error_outline,
                  message: postsProvider.errorMessage!,
                  actionLabel: 'Retry',
                  onAction: () => context.read<PostsProvider>().loadPosts(),
                )
              : postsProvider.posts.isEmpty
                  ? AppStateMessage(
                      icon: Icons.article_outlined,
                      message: 'No posts yet. Be the first to share something!',
                      actionLabel: 'Create Post',
                      onAction: () => context.push('/posts/create'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: postsProvider.posts.length +
                          (postsProvider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= postsProvider.posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final post = postsProvider.posts[index];
                        // --- REPLACED CODE STARTS HERE ---
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: post.images.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      post.images.first.imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null,
                            title: Text(post.title),
                            subtitle:
                                Text(post.authorUsername ?? 'Unknown author'),
                            onTap: () => context.push('/posts/${post.id}'),
                          ),
                        );
                      },
                    ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isLoggedIn =
              context.read<AuthProvider>().currentUser != null;
          if (!isLoggedIn) {
            context.push('/login');
          } else {
            context.push('/posts/create');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}