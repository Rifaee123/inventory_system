import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  final _controller = StreamController<UserProfile?>();

  SupabaseAuthRepository(this._client) {
    _client.auth.onAuthStateChange.listen((data) async {
      final user = await getCurrentUser();
      _controller.add(user);
    });
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      // If profile not found (PGRST116), try to create it manually as fallback
      // This makes the app robust against trigger failures
      if (e.toString().contains('PGRST116') ||
          e.toString().contains('0 rows')) {
        try {
          final username = session.user.userMetadata?['username'] ?? 'User';
          final newProfile = {
            'id': session.user.id,
            'username': username,
            'role': 'user', // Default to user
          };

          await _client.from('profiles').insert(newProfile);

          // Return the newly created profile
          // We can just construct it manually to save a round trip
          return UserProfile(
            id: session.user.id,
            username: username,
            role: UserRole.user,
            createdAt: DateTime.now(),
          );
        } catch (insertError) {
          // If insert fails explicitly, then we really have an issue
          return null;
        }
      }
      return null;
    }
  }

  @override
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    return getCurrentUser();
  }

  @override
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    // Supabase triggers should create the profile, but we can't guarantee it's instant.
    // However, for the user to be "logged in" and have a profile, we might need to wait or just return null and let authStateChanges handle it.
    // Standard Supabase flow: signUp -> authStateChange -> getCurrentUser
    // But we want to return the user here if possible.
    return getCurrentUser();
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Stream<UserProfile?> get authStateChanges => _controller.stream;
}
