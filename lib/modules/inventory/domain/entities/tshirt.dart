import 'package:equatable/equatable.dart';
import 'variant.dart';

class TShirt extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String? imageUrl;
  final double basePrice;
  final double? offerPrice;
  final int returnPolicyDays;
  final int priorityWeight;
  final bool isActive;
  final List<Variant> variants;

  const TShirt({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.imageUrl,
    required this.basePrice,
    this.offerPrice,
    required this.returnPolicyDays,
    required this.priorityWeight,
    required this.isActive,
    this.variants = const [],
  });

  factory TShirt.fromJson(Map<String, dynamic> json) {
    return TShirt(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String,
      imageUrl: json['image_url'] as String?,
      basePrice: (json['base_price'] as num).toDouble(),
      offerPrice: json['offer_price'] != null
          ? (json['offer_price'] as num).toDouble()
          : null,
      returnPolicyDays: (json['return_policy_days'] as num).toInt(),
      priorityWeight: (json['priority_weight'] as num).toInt(),
      isActive: json['is_active'] as bool? ?? true,
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((e) => Variant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'image_url': imageUrl,
      'base_price': basePrice,
      'offer_price': offerPrice,
      'return_policy_days': returnPolicyDays,
      'priority_weight': priorityWeight,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    categoryId,
    imageUrl,
    basePrice,
    offerPrice,
    returnPolicyDays,
    priorityWeight,
    isActive,
    variants,
  ];
}
