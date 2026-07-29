import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigation after success will be wired up once go_router
      // is introduced in Phase 5.
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 12),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Login',
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }
}