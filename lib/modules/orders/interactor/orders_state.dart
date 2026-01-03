import 'package:equatable/equatable.dart';
import '../domain/entities/order.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<Order> orders;
  final String? errorMessage;
  final String? selectedStatusFilter; // null means "All"
  final String? searchQuery;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.selectedStatusFilter,
    this.searchQuery,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<Order>? orders,
    String? errorMessage,
    String? selectedStatusFilter,
    String? searchQuery,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    errorMessage,
    selectedStatusFilter,
    searchQuery,
  ];
}
