import 'package:equatable/equatable.dart';
import '../../../../domain/entities/tshirt.dart';
import '../../../../domain/entities/category.dart';

enum InventoryStatus { initial, loading, success, failure }

class InventoryState extends Equatable {
  final InventoryStatus status;
  final List<TShirt> tshirts;
  final List<Category> categories;
  final String? errorMessage;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.tshirts = const [],
    this.categories = const [],
    this.errorMessage,
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<TShirt>? tshirts,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return InventoryState(
      status: status ?? this.status,
      tshirts: tshirts ?? this.tshirts,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tshirts, categories, errorMessage];
}
