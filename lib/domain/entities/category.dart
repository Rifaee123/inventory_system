import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final double taxPercentage;

  const Category({
    required this.id,
    required this.name,
    required this.taxPercentage,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      taxPercentage: (json['tax_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'tax_percentage': taxPercentage};
  }

  @override
  List<Object?> get props => [id, name, taxPercentage];
}
