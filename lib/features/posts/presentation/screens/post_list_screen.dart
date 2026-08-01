import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../logic/posts_provider.dart';

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
              ? Center(child: Text(postsProvider.errorMessage!))
              : postsProvider.posts.isEmpty
                  ? const Center(child: Text('No posts yet.'))
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
                        return ListTile(
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
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/posts/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}