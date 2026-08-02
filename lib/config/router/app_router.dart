import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/logic/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/posts/presentation/screens/post_list_screen.dart';
import '../../features/posts/presentation/screens/create_post_screen.dart';
import '../../features/posts/presentation/screens/post_detail_screen.dart';
import '../../features/posts/presentation/screens/edit_post_screen.dart';
import '../../features/shell/presentation/main_shell.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.currentUser != null;
      final path = state.matchedLocation;

      final isAuthScreen = path == '/login' || path == '/register';
      final requiresAuth = path == '/posts/create' || path.endsWith('/edit');

      if (!isLoggedIn && requiresAuth) {
        return '/login';
      }

      if (isLoggedIn && isAuthScreen) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/posts', builder: (context, state) => const PostListScreen()),
      GoRoute(path: '/posts/create', builder: (context, state) => const CreatePostScreen()),
      GoRoute(path: '/home', builder: (context, state) => const MainShell()),
      GoRoute(
        path: '/posts/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/posts/:postId/edit',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return EditPostScreen(postId: postId);
        },
      ),
    ],
  );
}