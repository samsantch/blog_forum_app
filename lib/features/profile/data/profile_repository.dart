import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> createProfile({required String userId}) async {
    await _supabaseClient.from('profiles').insert({
      'id': userId,
    });
  }

  Future<ProfileModel> getProfile({required String userId}) async {
    final response = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return ProfileModel.fromMap(response);
  }

  Future<void> updateProfile({
    required String userId,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabaseClient.from('profiles').update(updates).eq('id', userId);
  }

  Future<void> removeAvatar({required String userId}) async {
    await _supabaseClient.from('profiles').update({
      'avatar_url': null,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}