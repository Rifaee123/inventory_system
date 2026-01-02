import '../../domain/entities/order.dart';

class ProfitCalculatorService {
  /// Calculates Net Profit for a single order.
  /// Formula: (Sale Price * Qty) - (Cost Price * Qty) - Tax - Shipping
  double calculateOrderProfit(Order order) {
    double totalRevenue = 0;
    double totalCost = 0;

    for (var item in order.items) {
      totalRevenue += item.salePrice * item.quantity;
      totalCost += item.costPrice * item.quantity;
    }

    // Adjust validation: Revenue should match totalAmount roughly, but we trust the item breakdown
    // Net Profit = Revenue - Cost - Tax - Shipping
    return totalRevenue - totalCost - order.taxAmount - order.shippingCost;
  }

  /// Calculates total profit from a list of orders
  double calculateTotalProfit(List<Order> orders) {
    return orders.fold(0, (sum, order) => sum + calculateOrderProfit(order));
  }
}
