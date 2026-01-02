import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/locator.dart';
import '../../../../domain/entities/order.dart';
import '../../../../domain/entities/tshirt.dart';
import '../../../../domain/entities/variant.dart';
import '../../../../domain/repositories/order_repository.dart';
import '../../../../domain/repositories/inventory_repository.dart';
import '../../inventory/interactor/inventory_bloc.dart';
import '../../inventory/interactor/inventory_event.dart';
import '../../inventory/interactor/inventory_state.dart';
import '../interactor/orders_bloc.dart';
import '../interactor/orders_event.dart';
import '../interactor/orders_state.dart';
import '../../auth/interactor/auth_bloc.dart';
import '../../auth/interactor/auth_state.dart';
import '../../../../domain/entities/user_profile.dart';

class OrderFormPage extends StatelessWidget {
  final Order? order;

  const OrderFormPage({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              OrdersBloc(orderRepository: getIt<OrderRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              InventoryBloc(repository: getIt<InventoryRepository>())
                ..add(LoadInventory()),
        ),
      ],
      child: OrderFormView(order: order),
    );
  }
}

class OrderFormView extends StatefulWidget {
  final Order? order;

  const OrderFormView({super.key, this.order});

  @override
  State<OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends State<OrderFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _status = 'pending';
  final List<OrderItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _nameController.text = widget.order!.customerName;
      _emailController.text = widget.order!.customerEmail;
      _phoneController.text = widget.order!.customerPhone;
      _addressController.text = widget.order!.deliveryAddress;
      _status = widget.order!.status;
      _items.addAll(widget.order!.items);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _items.fold(
      0,
      (sum, item) => sum + (item.salePrice * item.quantity),
    );
  }

  double get _deliveryCharges {
    if (_subtotal >= 50 || _items.isEmpty) return 0;
    return 5.0;
  }

  double get _total => _subtotal + _deliveryCharges;

  void _addItem(TShirt tshirt, Variant variant) {
    setState(() {
      final existingIndex = _items.indexWhere(
        (item) => item.variantId == variant.id,
      );
      if (existingIndex != -1) {
        final existingItem = _items[existingIndex];
        _items[existingIndex] = OrderItem(
          id: existingItem.id,
          orderId: existingItem.orderId,
          variantId: existingItem.variantId,
          quantity: existingItem.quantity + 1,
          salePrice: tshirt.offerPrice ?? tshirt.basePrice,
          costPrice: tshirt.basePrice,
        );
      } else {
        _items.add(
          OrderItem(
            id: const Uuid().v4(),
            orderId: widget.order?.id ?? '',
            variantId: variant.id,
            quantity: 1,
            salePrice: tshirt.offerPrice ?? tshirt.basePrice,
            costPrice: tshirt.basePrice,
          ),
        );
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item to the order.'),
          ),
        );
        return;
      }

      final newOrder = Order(
        id: widget.order?.id ?? const Uuid().v4(),
        customerName: _nameController.text,
        customerEmail: _emailController.text,
        customerPhone: _phoneController.text,
        deliveryAddress: _addressController.text,
        totalAmount: _total,
        taxAmount: 0,
        shippingCost: 0,
        deliveryCharges: _deliveryCharges,
        status: _status,
        createdAt: widget.order?.createdAt ?? DateTime.now(),
        items: _items,
      );

      if (widget.order == null) {
        context.read<OrdersBloc>().add(CreateOrder(newOrder));
      } else {
        context.read<OrdersBloc>().add(UpdateOrder(newOrder));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState.user?.role == UserRole.admin;
        return BlocListener<OrdersBloc, OrdersState>(
          listener: (context, state) {
            if (state.status == OrdersStatus.success) {
              context.pop(true);
            } else if (state.status == OrdersStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to save order'),
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Text(
                widget.order == null ? 'Create New Order' : 'Edit Order',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              actions: [
                TextButton(
                  onPressed: _save,
                  child: Text(
                    'Save Order',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1313EC),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Customer Information'),
                    const SizedBox(height: 16),
                    _buildCustomerInfoFields(),
                    if (isAdmin) ...[
                      const SizedBox(height: 32),
                      _buildSectionHeader('Order Details'),
                      const SizedBox(height: 16),
                      _buildOrderStatusField(),
                    ],
                    const SizedBox(height: 32),
                    _buildSectionHeader('Order Items'),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                    const SizedBox(height: 16),
                    _buildAddItemButton(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Order Summary'),
                    const SizedBox(height: 16),
                    _buildSummaryCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildCustomerInfoFields() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Customer Name', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(
              _emailController,
              'Email Address',
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _phoneController,
              'Phone Number',
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _addressController,
              'Delivery Address',
              Icons.location_on,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildOrderStatusField() {
    final statuses = [
      'pending',
      'packing',
      'dispatched',
      'shipped',
      'delivered',
      'cancelled',
    ];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DropdownButtonFormField<String>(
          value: _status,
          decoration: InputDecoration(
            labelText: 'Order Status',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: statuses.map((s) {
            return DropdownMenuItem(value: s, child: Text(s.toUpperCase()));
          }).toList(),
          onChanged: (value) => setState(() => _status = value!),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              'No items added yet',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _items[index];
            TShirt? foundTshirt;
            Variant? foundVariant;
            for (final t in state.tshirts) {
              for (final v in t.variants) {
                if (v.id == item.variantId) {
                  foundTshirt = t;
                  foundVariant = v;
                  break;
                }
              }
            }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFF1F5F9),
                  child: Text(
                    '${item.quantity}x',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(foundTshirt?.name ?? 'Loading...'),
                subtitle: Text(
                  'Size: ${foundVariant?.size ?? "-"} | Color: ${foundVariant?.color ?? "-"}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${(item.salePrice * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showProductPicker,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFF1313EC)),
          foregroundColor: const Color(0xFF1313EC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: this.context.read<InventoryBloc>(),
        child: const ProductPickerSheet(),
      ),
    ).then((result) {
      if (result != null && result is Map) {
        _addItem(result['tshirt'] as TShirt, result['variant'] as Variant);
      }
    });
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Delivery Charges',
              '\$${_deliveryCharges.toStringAsFixed(2)}',
            ),
            const Divider(height: 24, color: Color(0xFFCBD5E1)),
            _buildSummaryRow(
              'Total',
              '\$${_total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? const Color(0xFF1313EC) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class ProductPickerSheet extends StatelessWidget {
  const ProductPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Product',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state.status == InventoryStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: state.tshirts.length,
                  itemBuilder: (context, index) {
                    final tshirt = state.tshirts[index];
                    return ExpansionTile(
                      leading: tshirt.imageUrl != null
                          ? Image.network(
                              tshirt.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image),
                      title: Text(tshirt.name),
                      subtitle: Text('\$${tshirt.basePrice}'),
                      children: tshirt.variants.map((variant) {
                        return ListTile(
                          title: Text(
                            'Size: ${variant.size} | Color: ${variant.color}',
                          ),
                          subtitle: Text('Stock: ${variant.stockQuantity}'),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () => context.pop({
                            'tshirt': tshirt,
                            'variant': variant,
                          }),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
