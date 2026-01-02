import 'package:equatable/equatable.dart';

enum UserRole { admin, user }

class UserProfile extends Equatable {
  final String id;
  final String username;
  final UserRole role;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String),
        orElse: () => UserRole.user,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, username, role, createdAt];
}
