import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';

/// Temporary placeholder for the logged-in area of the app.
/// Will eventually be replaced/expanded once Posts (Phase 7) exist.
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authRepository.logout();
              debugPrint('Current user after logout: ${_authRepository.currentUser}');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Logged in!'),
      ),
    );
  }
}