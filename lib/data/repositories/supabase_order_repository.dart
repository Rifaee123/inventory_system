import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _client;

  SupabaseOrderRepository(this._client);

  @override
  Future<List<Order>> getOrders({
    String? statusFilter,
    String? searchQuery,
  }) async {
    var query = _client.from('orders').select('*, order_items(*)');

    // Apply status filter if provided
    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.eq('status', statusFilter);
    }

    // Apply search query if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Searching by order ID, customer name, or customer email
      query = query.or(
        'id.ilike.%$searchQuery%,customer_name.ilike.%$searchQuery%,customer_email.ilike.%$searchQuery%',
      );
    }

    final response = await query.order('created_at', ascending: false);

    // Note: In a real app we would join with user table or similar for customer info
    // For now we map raw response to Order entity
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  @override
  Future<Order> getOrder(String id) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .single();

    return Order.fromJson(response);
  }

  @override
  Future<void> createOrder(Order order) async {
    // Insert order first
    final orderResponse = await _client
        .from('orders')
        .insert({
          'total_amount': order.totalAmount,
          'tax_amount': order.taxAmount,
          'shipping_cost': order.shippingCost,
          'delivery_charges': order.deliveryCharges,
          'status': order.status,
          'customer_name': order.customerName,
          'customer_email': order.customerEmail,
          'customer_phone': order.customerPhone,
          'delivery_address': order.deliveryAddress,
        })
        .select()
        .single();

    final orderId = orderResponse['id'] as String;

    // Insert order items as a batch
    if (order.items.isNotEmpty) {
      final itemsToInsert = order.items
          .map(
            (item) => {
              'order_id': orderId,
              'variant_id': item.variantId,
              'quantity': item.quantity,
              'sale_price': item.salePrice,
              'cost_price': item.costPrice,
            },
          )
          .toList();

      await _client.from('order_items').insert(itemsToInsert);
    }
  }

  @override
  Future<void> updateOrder(Order order) async {
    await _client
        .from('orders')
        .update({
          'total_amount': order.totalAmount,
          'tax_amount': order.taxAmount,
          'shipping_cost': order.shippingCost,
          'delivery_charges': order.deliveryCharges,
          'status': order.status,
          'customer_name': order.customerName,
          'customer_email': order.customerEmail,
          'customer_phone': order.customerPhone,
          'delivery_address': order.deliveryAddress,
        })
        .eq('id', order.id);

    // Note: For simplicity, not updating order items here
    // In a real app, you'd need to sync order items (delete + recreate or update)
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _client.from('orders').delete().eq('id', id);
    // order_items will be deleted automatically due to CASCADE
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', id);
  }

  @override
  double calculateDeliveryCharges(double orderTotal) {
    // Simple flat-rate delivery charges
    // Free delivery for orders >= $50, else $5
    if (orderTotal >= 50) {
      return 0.0;
    }
    return 5.0;
  }
}
