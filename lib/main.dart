import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'config/router/app_router.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/posts/logic/posts_provider.dart';
import 'features/comments/logic/comments_provider.dart';
import 'core/theme/app_theme.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthProvider _authProvider = AuthProvider();
  late final AppRouter _appRouter = AppRouter(_authProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => CommentsProvider()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: _appRouter.router,
      ),
    );
  }
}