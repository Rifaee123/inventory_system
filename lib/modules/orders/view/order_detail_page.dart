import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/locator.dart';
import '../domain/entities/order.dart';
import '../domain/repositories/order_repository.dart';
import '../../inventory/interactor/inventory_bloc.dart';
import '../../inventory/interactor/inventory_event.dart';
import '../../inventory/domain/repositories/inventory_repository.dart';
import '../../inventory/domain/repositories/category_repository.dart';
import '../interactor/orders_bloc.dart';
import '../interactor/orders_event.dart';
import '../interactor/orders_state.dart';
import '../../auth/interactor/auth_bloc.dart';
import '../../auth/interactor/auth_state.dart';
import '../../auth/domain/entities/user_profile.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              OrdersBloc(orderRepository: getIt<OrderRepository>())
                ..add(LoadOrders()),
        ),
        BlocProvider(
          create: (context) => InventoryBloc(
            repository: getIt<InventoryRepository>(),
            categoryRepository: getIt<CategoryRepository>(),
          )..add(LoadInventory()),
        ),
      ],
      child: OrderDetailView(orderId: orderId),
    );
  }
}

class OrderDetailView extends StatefulWidget {
  final String orderId;

  const OrderDetailView({super.key, required this.orderId});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  bool _wasUpdated = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState.user?.role == UserRole.admin;
        return BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            final order = state.orders
                .where((o) => o.id == widget.orderId)
                .firstOrNull;

            if (state.status == OrdersStatus.loading && order == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (order == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Order Not Found')),
                body: const Center(
                  child: Text('The requested order was not found.'),
                ),
              );
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(_wasUpdated),
                ),
                title: Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                actions: [
                  _buildStatusBadge(order.status),
                  const SizedBox(width: 16),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNarrow)
                          Column(
                            children: [
                              _buildSectionCard(
                                'Customer Information',
                                Icons.person_outlined,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow('Name', order.customerName),
                                    _buildDetailRow(
                                      'Email',
                                      order.customerEmail,
                                    ),
                                    _buildDetailRow(
                                      'Phone',
                                      order.customerPhone,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSectionCard(
                                'Delivery Address',
                                Icons.location_on_outlined,
                                Text(
                                  order.deliveryAddress,
                                  style: GoogleFonts.inter(
                                    height: 1.5,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildSectionCard(
                                'Order Items',
                                Icons.shopping_bag_outlined,
                                _buildItemsList(context, order),
                              ),
                              const SizedBox(height: 24),
                              _buildSectionCard(
                                'Financial Summary',
                                Icons.payments_outlined,
                                _buildSummary(order),
                              ),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildSectionCard(
                                      'Customer Information',
                                      Icons.person_outlined,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                            'Name',
                                            order.customerName,
                                          ),
                                          _buildDetailRow(
                                            'Email',
                                            order.customerEmail,
                                          ),
                                          _buildDetailRow(
                                            'Phone',
                                            order.customerPhone,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildSectionCard(
                                      'Delivery Address',
                                      Icons.location_on_outlined,
                                      Text(
                                        order.deliveryAddress,
                                        style: GoogleFonts.inter(
                                          height: 1.5,
                                          color: const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildSectionCard(
                                      'Order Items',
                                      Icons.shopping_bag_outlined,
                                      _buildItemsList(context, order),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildSectionCard(
                                      'Financial Summary',
                                      Icons.payments_outlined,
                                      _buildSummary(order),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 32),
                        if (isAdmin) _buildActionButtons(context, order),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget child) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1313EC), size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, Order order) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final item = order.items[index];
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item ID: ${item.variantId.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Qty: ${item.quantity}'),
                ],
              ),
            ),
            Text('\$${(item.salePrice * item.quantity).toStringAsFixed(2)}'),
          ],
        );
      },
    );
  }

  Widget _buildSummary(Order order) {
    return Column(
      children: [
        _buildSummaryRow(
          'Subtotal',
          '\$${(order.totalAmount - order.deliveryCharges).toStringAsFixed(2)}',
        ),
        const SizedBox(height: 12),
        _buildSummaryRow(
          'Delivery',
          '\$${order.deliveryCharges.toStringAsFixed(2)}',
        ),
        const Divider(height: 32),
        _buildSummaryRow(
          'Total',
          '\$${order.totalAmount.toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF1313EC) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    String? nextStatus;
    String? nextAction;

    switch (order.status.toLowerCase()) {
      case 'pending':
        nextStatus = 'packing';
        nextAction = 'Accept & Pack';
        break;
      case 'packing':
        nextStatus = 'dispatched';
        nextAction = 'Dispatch';
        break;
      case 'dispatched':
        nextStatus = 'shipped';
        nextAction = 'Ship';
        break;
      case 'shipped':
        nextStatus = 'delivered';
        nextAction = 'Mark Delivered';
        break;
    }

    if (nextStatus == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (order.status == 'pending')
          OutlinedButton(
            onPressed: () {
              setState(() => _wasUpdated = true);
              context.read<OrdersBloc>().add(
                UpdateOrderStatus(order.id, 'cancelled'),
              );
            },
            child: const Text('Cancel'),
          ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            setState(() => _wasUpdated = true);
            context.read<OrdersBloc>().add(
              UpdateOrderStatus(order.id, nextStatus!),
            );
          },
          child: Text(nextAction!),
        ),
      ],
    );
  }
}
