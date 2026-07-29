import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles all direct communication with Supabase Auth.
///
/// This is the ONLY class in the `auth` feature allowed to reference
/// `Supabase.instance.client`. Logic and UI layers depend on this
/// class's methods, never on Supabase directly.
class AuthRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }

  User? get currentUser => _supabaseClient.auth.currentUser;
}

