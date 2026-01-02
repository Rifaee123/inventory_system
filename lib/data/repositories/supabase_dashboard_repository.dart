import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order.dart' as entity;
import '../../domain/repositories/dashboard_repository.dart';

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    // Fetch all non-cancelled orders
    final ordersResponse = await _client
        .from('orders')
        .select()
        .neq('status', 'cancelled');

    final orders = ordersResponse as List;
    double totalSales = 0;
    double taxLiability = 0;
    int totalOrders = orders.length;

    for (var order in orders) {
      totalSales += (order['total_amount'] as num).toDouble();
      taxLiability += (order['tax_amount'] as num).toDouble();
    }

    // Fetch profit and items sold from order_items
    // We filter by non-cancelled orders using a subquery-like approach if needed,
    // but easier to just fetch and filter in memory if volume is manageable
    // OR just fetch all and assume order_items only exist for valid orders (mostly true)
    // Better: Join with orders to check status
    final itemsResponse = await _client
        .from('order_items')
        .select('quantity, sale_price, cost_price, orders!inner(status)')
        .neq('orders.status', 'cancelled');

    final items = itemsResponse as List;
    double netProfit = 0;
    int itemsSold = 0;

    for (var item in items) {
      final qty = item['quantity'] as int;
      final sale = (item['sale_price'] as num).toDouble();
      final cost = (item['cost_price'] as num).toDouble();

      itemsSold += qty;
      netProfit += (sale - cost) * qty;
    }

    return {
      'totalSales': totalSales,
      'netProfit': netProfit,
      'totalOrders': totalOrders,
      'taxLiability': taxLiability,
      'itemsSold': itemsSold,
    };
  }

  @override
  Future<List<double>> getWeeklySales() async {
    final sevenDaysAgo = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String();

    final response = await _client
        .from('orders')
        .select('total_amount, created_at')
        .neq('status', 'cancelled')
        .gte('created_at', sevenDaysAgo);

    final data = response as List;
    final List<double> weeklySales = List.filled(7, 0.0);
    final now = DateTime.now();

    for (var order in data) {
      final createdAt = DateTime.parse(order['created_at']);
      // Calculate difference in days by comparing date parts only
      final orderDate = DateTime(
        createdAt.year,
        createdAt.month,
        createdAt.day,
      );
      final todayDate = DateTime(now.year, now.month, now.day);
      final dayIndex = 6 - todayDate.difference(orderDate).inDays;

      if (dayIndex >= 0 && dayIndex < 7) {
        weeklySales[dayIndex] += (order['total_amount'] as num).toDouble();
      }
    }

    return weeklySales;
  }

  @override
  Future<Map<String, double>> getCategorySales() async {
    final response = await _client
        .from('order_items')
        .select(
          'quantity, sale_price, variants(tshirts(categories(name))), orders!inner(status)',
        )
        .neq('orders.status', 'cancelled');

    final items = response as List;
    final Map<String, double> categorySales = {};

    for (var item in items) {
      try {
        final categoryName =
            item['variants']['tshirts']['categories']['name'] as String;
        final revenue =
            (item['quantity'] as int) * (item['sale_price'] as num).toDouble();

        categorySales[categoryName] =
            (categorySales[categoryName] ?? 0) + revenue;
      } catch (e) {
        // Handle cases where category might be missing
        categorySales['Uncategorized'] =
            (categorySales['Uncategorized'] ?? 0) +
            ((item['quantity'] as int) *
                (item['sale_price'] as num).toDouble());
      }
    }

    return categorySales;
  }

  @override
  Future<Map<String, int>> getTopSizes() async {
    final response = await _client
        .from('order_items')
        .select('quantity, variants(size), orders!inner(status)')
        .neq('orders.status', 'cancelled');

    final items = response as List;
    final Map<String, int> topSizes = {};

    for (var item in items) {
      final size = item['variants']['size'] as String;
      final qty = item['quantity'] as int;
      topSizes[size] = (topSizes[size] ?? 0) + qty;
    }

    return topSizes;
  }

  @override
  Future<List<entity.Order>> getRecentOrders() async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false)
        .limit(5);

    return (response as List).map((e) => entity.Order.fromJson(e)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTopProducts() async {
    final response = await _client
        .from('order_items')
        .select(
          'quantity, sale_price, variants(tshirts(name, image_url)), orders!inner(status)',
        )
        .neq('orders.status', 'cancelled');

    final items = response as List;
    final Map<String, Map<String, dynamic>> productStats = {};

    for (var item in items) {
      final tshirt = item['variants']['tshirts'] as Map<String, dynamic>;
      final name = tshirt['name'] as String;
      final imageUrl = tshirt['image_url'] as String?;
      final qty = item['quantity'] as int;
      final revenue = qty * (item['sale_price'] as num).toDouble();

      if (productStats.containsKey(name)) {
        productStats[name]!['quantity'] =
            (productStats[name]!['quantity'] as int) + qty;
        productStats[name]!['revenue'] =
            (productStats[name]!['revenue'] as double) + revenue;
      } else {
        productStats[name] = {
          'name': name,
          'image_url': imageUrl,
          'quantity': qty,
          'revenue': revenue,
        };
      }
    }

    // Sort by quantity descending
    final result = productStats.values.toList();
    result.sort(
      (a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int),
    );

    return result.take(5).toList(); // Return top 5
  }
}
