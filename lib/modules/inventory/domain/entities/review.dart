import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String tshirtId;
  final String userName;
  final int rating;
  final String? comment;
  final String status;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.tshirtId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.status,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      tshirtId: json['tshirt_id'] as String,
      userName: json['user_name'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    tshirtId,
    userName,
    rating,
    comment,
    status,
    createdAt,
  ];
}
