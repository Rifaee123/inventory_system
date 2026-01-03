import 'dart:async';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<UserProfile?>();

  MockAuthRepository() {
    // Automatically emit "logged in" state on initialization
    Future.delayed(Duration.zero, () {
      _controller.add(_getMockUser());
    });
  }

  UserProfile _getMockUser() {
    return UserProfile(
      id: 'mock-admin-id',
      username: 'AdminUser',
      role: UserRole.admin, // Force Admin role
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _getMockUser();
  }

  @override
  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    // Always succeed
    final user = _getMockUser();
    _controller.add(user);
    return user;
  }

  @override
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // Always succeed
    final user = _getMockUser();
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    // Simulate sign out but usually in mock mode we want to stay logged in or allow re-login easily
    _controller.add(null);
  }

  @override
  Stream<UserProfile?> get authStateChanges => _controller.stream;
}
