import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/services/storage_service.dart';
import '../../../posts/logic/posts_provider.dart';
import '../../../../core/widgets/app_state_message.dart';
import 'package:go_router/go_router.dart';

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
  bool _isRemovingPhoto = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<PostsProvider>().loadMyPosts(authorId: userId);
      }
    });
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

  Future<void> _handleRemovePhoto() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _isRemovingPhoto = true);

    try {
      await _profileRepository.removeAvatar(userId: userId);
      await _loadProfile();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to remove photo.');
    } finally {
      setState(() => _isRemovingPhoto = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Widget _buildMyPosts(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();

    if (postsProvider.isLoadingMyPosts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (postsProvider.myPostsError != null) {
      return AppStateMessage(
        icon: Icons.error_outline,
        message: postsProvider.myPostsError!,
      );
    }

    if (postsProvider.myPosts.isEmpty) {
      return const AppStateMessage(
        icon: Icons.article_outlined,
        message: "You haven't posted anything yet.",
      );
    }

    return Column(
      children: postsProvider.myPosts.map((post) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
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
            title: Text(post.title ?? 'Untitled'),
            subtitle: Text(
              post.content ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => context.push('/posts/${post.id}'),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  AppButton(
                    label: 'Change Photo',
                    isLoading: _isUploadingPhoto,
                    onPressed: _handleChangePhoto,
                  ),
                  if (_profile?.avatarUrl != null)
                    TextButton(
                      onPressed:
                          _isRemovingPhoto ? null : _handleRemovePhoto,
                      child: _isRemovingPhoto
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Remove Photo'),
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
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Posts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMyPosts(context),
                ],
              ),
            ),
    );
  }
}