import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/logic/auth_provider.dart';
import '../../posts/presentation/screens/post_list_screen.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().currentUser != null;

    final screens = [
      const PostListScreen(),
      if (isLoggedIn) const ProfileScreen(),
    ];

    final safeIndex = _selectedIndex < screens.length ? _selectedIndex : 0;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          if (!isLoggedIn && index == 1) {
            context.go('/login');
            return;
          }
          setState(() => _selectedIndex = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Posts',
          ),
          if (isLoggedIn)
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            )
          else
            const NavigationDestination(
              icon: Icon(Icons.login),
              selectedIcon: Icon(Icons.login),
              label: 'Login',
            ),
        ],
      ),
    );
  }
}