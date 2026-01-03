import 'package:equatable/equatable.dart';

class Variant extends Equatable {
  final String id;
  final String tshirtId;
  final String size;
  final String color;
  final int stockQuantity;

  const Variant({
    required this.id,
    required this.tshirtId,
    required this.size,
    required this.color,
    required this.stockQuantity,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'] as String,
      tshirtId: json['tshirt_id'] as String,
      size: json['size'] as String,
      color: json['color'] as String,
      stockQuantity: (json['stock_quantity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tshirt_id': tshirtId,
      'size': size,
      'color': color,
      'stock_quantity': stockQuantity,
    };
  }

  Variant copyWith({
    String? id,
    String? tshirtId,
    String? size,
    String? color,
    int? stockQuantity,
  }) {
    return Variant(
      id: id ?? this.id,
      tshirtId: tshirtId ?? this.tshirtId,
      size: size ?? this.size,
      color: color ?? this.color,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  @override
  List<Object?> get props => [id, tshirtId, size, color, stockQuantity];
}
