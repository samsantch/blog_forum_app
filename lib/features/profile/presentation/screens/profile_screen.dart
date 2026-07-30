import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileRepository = ProfileRepository();

  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    try {
      final profile = await _profileRepository.getProfile(userId: userId);
      setState(() {
        _profile = profile;
        _usernameController.text = profile.username ?? '';
        _bioController.text = profile.bio ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSave() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _profileRepository.updateProfile(
        userId: userId,
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile.';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    child: Icon(Icons.person, size: 48),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _usernameController,
                    label: 'Username',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _bioController,
                    label: 'Bio',
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Save',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ),
    );
  }
}