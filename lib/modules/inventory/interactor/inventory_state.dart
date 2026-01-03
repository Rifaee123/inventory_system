import 'package:equatable/equatable.dart';
import '../domain/entities/tshirt.dart';
import '../domain/entities/category.dart';

enum InventoryStatus { initial, loading, success, failure }

class InventoryState extends Equatable {
  final InventoryStatus status;
  final List<Category> categories;
  final List<TShirt> tshirts;
  final List<TShirt> filteredTshirts;
  final String? errorMessage;

  // Stats
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalValue;

  // Filter State
  final String? selectedCategoryId;
  final String? stockFilter; // 'low', 'out', or null

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.categories = const [],
    this.tshirts = const [],
    this.filteredTshirts = const [],
    this.errorMessage,
    this.totalProducts = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.totalValue = 0.0,
    this.selectedCategoryId,
    this.stockFilter,
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<Category>? categories,
    List<TShirt>? tshirts,
    List<TShirt>? filteredTshirts,
    String? errorMessage,
    int? totalProducts,
    int? lowStockCount,
    int? outOfStockCount,
    double? totalValue,
    String? selectedCategoryId,
    String? stockFilter,
  }) {
    return InventoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      tshirts: tshirts ?? this.tshirts,
      filteredTshirts: filteredTshirts ?? this.filteredTshirts,
      errorMessage: errorMessage ?? this.errorMessage,
      totalProducts: totalProducts ?? this.totalProducts,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      totalValue: totalValue ?? this.totalValue,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      stockFilter: stockFilter ?? this.stockFilter,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    tshirts,
    filteredTshirts,
    errorMessage,
    totalProducts,
    lowStockCount,
    outOfStockCount,
    totalValue,
    selectedCategoryId,
    stockFilter,
  ];
}
