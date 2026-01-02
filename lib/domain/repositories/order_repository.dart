import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({String? statusFilter, String? searchQuery});
  Future<Order> getOrder(String id);
  Future<void> createOrder(Order order);
  Future<void> updateOrder(Order order);
  Future<void> deleteOrder(String id);
  Future<void> updateOrderStatus(String id, String status);
  double calculateDeliveryCharges(double orderTotal);
}
