import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  });

  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String username,
  });

  Future<void> signOut();

  Future<UserProfile?> getCurrentUser();

  Stream<UserProfile?> get authStateChanges;
}
