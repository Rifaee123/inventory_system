import 'package:inventory_system/modules/orders/domain/entities/order.dart';

abstract class DashboardRepository {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<double>> getWeeklySales();
  Future<Map<String, double>> getCategorySales();
  Future<Map<String, int>> getTopSizes();
  Future<List<Order>> getRecentOrders();
  Future<List<Map<String, dynamic>>> getTopProducts();
}
