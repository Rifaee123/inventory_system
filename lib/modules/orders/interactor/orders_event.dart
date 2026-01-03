import 'package:equatable/equatable.dart';
import '../domain/entities/order.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  final String? statusFilter;
  final String? searchQuery;

  const LoadOrders({this.statusFilter, this.searchQuery});

  @override
  List<Object?> get props => [statusFilter, searchQuery];
}

class CreateOrder extends OrdersEvent {
  final Order order;

  const CreateOrder(this.order);

  @override
  List<Object> get props => [order];
}

class UpdateOrder extends OrdersEvent {
  final Order order;

  const UpdateOrder(this.order);

  @override
  List<Object> get props => [order];
}

class DeleteOrder extends OrdersEvent {
  final String orderId;

  const DeleteOrder(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class UpdateOrderStatus extends OrdersEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}
