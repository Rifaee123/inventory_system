import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../interactor/orders_bloc.dart';
import '../interactor/orders_event.dart';
import '../interactor/orders_state.dart';
import '../../auth/interactor/auth_bloc.dart';
import '../../auth/interactor/auth_state.dart';
import '../../../domain/entities/user_profile.dart';

import '../../../../core/services/locator.dart';
import '../../../../domain/repositories/order_repository.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OrdersBloc(orderRepository: getIt<OrderRepository>())
            ..add(LoadOrders()),
      child: const OrdersView(),
    );
  }
}

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState.user?.role == UserRole.admin;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F8),
          body: Column(
            children: [
              // Sticky Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildHeaderTitle(),
                              _buildCreateButton(context),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderTitle(),
                              const SizedBox(height: 16),
                              _buildCreateButton(context),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final searchField = Container(
                          constraints: const BoxConstraints(maxWidth: 450),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              context.read<OrdersBloc>().add(
                                LoadOrders(searchQuery: value),
                              );
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Search by Order ID, Customer, or Email...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        );

                        final statusChips =
                            BlocBuilder<OrdersBloc, OrdersState>(
                              builder: (context, state) {
                                final statuses = [
                                  {'label': 'All', 'value': null},
                                  {'label': 'Pending', 'value': 'pending'},
                                  {'label': 'Packing', 'value': 'packing'},
                                  {
                                    'label': 'Dispatched',
                                    'value': 'dispatched',
                                  },
                                  {'label': 'Shipped', 'value': 'shipped'},
                                  {'label': 'Delivered', 'value': 'delivered'},
                                ];

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: statuses.map((s) {
                                      final isSelected =
                                          state.selectedStatusFilter ==
                                          s['value'];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(s['label']!),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            if (selected) {
                                              context.read<OrdersBloc>().add(
                                                LoadOrders(
                                                  statusFilter: s['value'],
                                                ),
                                              );
                                            }
                                          },
                                          selectedColor: const Color(
                                            0xFF1313EC,
                                          ).withOpacity(0.1),
                                          labelStyle: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF1313EC)
                                                : Colors.grey[600],
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            side: BorderSide(
                                              color: isSelected
                                                  ? const Color(0xFF1313EC)
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            );

                        if (constraints.maxWidth < 900) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              searchField,
                              const SizedBox(height: 16),
                              statusChips,
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(child: searchField),
                              const SizedBox(width: 24),
                              Expanded(flex: 2, child: statusChips),
                              const Spacer(),
                              if (isAdmin)
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download, size: 20),
                                  label: const Text('Export'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[700],
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    textStyle: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) {
                    if (state.status == OrdersStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                horizontalMargin: 24,
                                columnSpacing: 24,
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.grey[50]!.withOpacity(0.5),
                                ),
                                columns: [
                                  _buildHeader('ORDER ID'),
                                  _buildHeader('CUSTOMER'),
                                  _buildHeader('DATE'),
                                  _buildHeader('STATUS'),
                                  _buildHeader('TOTAL', align: TextAlign.right),
                                  _buildHeader(
                                    'ACTIONS',
                                    align: TextAlign.right,
                                  ),
                                ],
                                rows: state.orders.map<DataRow>((order) {
                                  return DataRow(
                                    onSelectChanged: (_) async {
                                      final result = await context.push(
                                        '/orders/${order.id}',
                                      );
                                      if (result == true && context.mounted) {
                                        context.read<OrdersBloc>().add(
                                          LoadOrders(),
                                        );
                                      }
                                    },
                                    cells: [
                                      DataCell(
                                        Text(
                                          order.id.substring(0, 8),
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1313EC),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.grey[200],
                                              child: Text(
                                                _getInitials(
                                                  order.customerName,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    order.customerName,
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                        0xFF0F172A,
                                                      ),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    order.customerEmail,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(order.createdAt),
                                          style: GoogleFonts.inter(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      DataCell(_buildStatusBadge(order.status)),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '\$${order.totalAmount.toStringAsFixed(2)}',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isAdmin &&
                                                  order.status == 'pending')
                                                TextButton(
                                                  onPressed: () {
                                                    context
                                                        .read<OrdersBloc>()
                                                        .add(
                                                          UpdateOrderStatus(
                                                            order.id,
                                                            'packing',
                                                          ),
                                                        );
                                                  },
                                                  child: const Text('Accept'),
                                                ),
                                              if (isAdmin &&
                                                  order.status == 'packing')
                                                TextButton(
                                                  onPressed: () {
                                                    context
                                                        .read<OrdersBloc>()
                                                        .add(
                                                          UpdateOrderStatus(
                                                            order.id,
                                                            'dispatched',
                                                          ),
                                                        );
                                                  },
                                                  child: const Text('Dispatch'),
                                                ),
                                              if (isAdmin &&
                                                  order.status == 'dispatched')
                                                TextButton(
                                                  onPressed: () {
                                                    context
                                                        .read<OrdersBloc>()
                                                        .add(
                                                          UpdateOrderStatus(
                                                            order.id,
                                                            'shipped',
                                                          ),
                                                        );
                                                  },
                                                  child: const Text('Ship'),
                                                ),
                                              if (isAdmin &&
                                                  order.status == 'shipped')
                                                TextButton(
                                                  onPressed: () {
                                                    context
                                                        .read<OrdersBloc>()
                                                        .add(
                                                          UpdateOrderStatus(
                                                            order.id,
                                                            'delivered',
                                                          ),
                                                        );
                                                  },
                                                  child: const Text('Deliver'),
                                                ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.visibility_outlined,
                                                  size: 20,
                                                ),
                                                color: Colors.grey[400],
                                                onPressed: () async {
                                                  final result = await context
                                                      .push(
                                                        '/orders/${order.id}',
                                                      );
                                                  if (result == true &&
                                                      context.mounted) {
                                                    context
                                                        .read<OrdersBloc>()
                                                        .add(LoadOrders());
                                                  }
                                                },
                                              ),
                                              if (isAdmin)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 20,
                                                  ),
                                                  color: Colors.grey[400],
                                                  onPressed: () async {
                                                    final result = await context
                                                        .push(
                                                          '/orders/edit/${order.id}',
                                                          extra: order,
                                                        );
                                                    if (result == true &&
                                                        context.mounted) {
                                                      context
                                                          .read<OrdersBloc>()
                                                          .add(LoadOrders());
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isNarrow = constraints.maxWidth < 600;
                                  final footerContent = [
                                    Text(
                                      'Showing 1 to ${state.orders.length} of ${state.orders.length} results',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    if (isNarrow) const SizedBox(height: 12),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildPaginationBtn(Icons.chevron_left),
                                        _buildPaginationBtn(
                                          '1',
                                          isActive: true,
                                        ),
                                        _buildPaginationBtn(
                                          Icons.chevron_right,
                                        ),
                                      ],
                                    ),
                                  ];

                                  if (isNarrow) {
                                    return Column(children: footerContent);
                                  }

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: footerContent,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DataColumn _buildHeader(String label, {TextAlign align = TextAlign.left}) {
    return DataColumn(
      label: Expanded(
        child: Text(
          label,
          textAlign: align,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toLowerCase()) {
      case 'delivered':
        bg = Colors.green.shade50;
        text = Colors.green.shade700;
        break;
      case 'shipped':
        bg = Colors.blue.shade50;
        text = Colors.blue.shade700;
        break;
      case 'dispatched':
        bg = Colors.indigo.shade50;
        text = Colors.indigo.shade700;
        break;
      case 'packing':
        bg = Colors.orange.shade50;
        text = Colors.orange.shade800;
        break;
      case 'pending':
        bg = Colors.amber.shade50;
        text = Colors.amber.shade800;
        break;
      case 'cancelled':
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: text.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPaginationBtn(dynamic content, {bool isActive = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 36),
      height: 36,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1313EC).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? const Color(0xFF1313EC) : Colors.grey[300]!,
        ),
      ),
      child: Center(
        child: content is String
            ? Text(
                content,
                style: TextStyle(
                  color: isActive ? const Color(0xFF1313EC) : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              )
            : Icon(content as IconData, size: 20, color: Colors.grey[500]),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orders',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage and track all customer orders across channels.',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await context.push('/orders/add');
        if (result == true && context.mounted) {
          context.read<OrdersBloc>().add(LoadOrders());
        }
      },
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Create New Order'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1313EC),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 4,
        shadowColor: const Color(0xFF1313EC).withOpacity(0.3),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
