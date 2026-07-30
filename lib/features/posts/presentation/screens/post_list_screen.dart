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
  @override
  void initState() {
    super.initState();
    context.read<PostsProvider>().loadPosts();
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
                      itemCount: postsProvider.posts.length,
                      itemBuilder: (context, index) {
                        final post = postsProvider.posts[index];
                        return ListTile(
                          title: Text(post.title),
                          subtitle: Text(
                            post.authorUsername ?? 'Unknown author',
                          ),
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