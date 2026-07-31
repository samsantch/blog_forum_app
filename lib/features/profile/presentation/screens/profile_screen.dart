import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileRepository = ProfileRepository();
  final _storageService = StorageService();

  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
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

  Future<void> _handleChangePhoto() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final fileBytes = await pickedFile.readAsBytes();
      final fileExtension = pickedFile.path.split('.').last;

      final avatarUrl = await _storageService.uploadFile(
        bucket: 'avatars',
        path: '$userId.$fileExtension',
        fileBytes: fileBytes,
        contentType: 'image/$fileExtension',
      );

      await _profileRepository.updateProfile(
        userId: userId,
        avatarUrl: avatarUrl,
      );

      await _loadProfile();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload photo.';
      });
    } finally {
      setState(() => _isUploadingPhoto = false);
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
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _profile?.avatarUrl != null
                        ? NetworkImage(_profile!.avatarUrl!)
                        : null,
                    child: _profile?.avatarUrl == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isUploadingPhoto ? null : _handleChangePhoto,
                    child: _isUploadingPhoto
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Change Photo'),
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