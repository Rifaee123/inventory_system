import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/services/locator.dart';
import '../../../../domain/repositories/inventory_repository.dart';
import '../interactor/inventory_bloc.dart';
import '../interactor/inventory_event.dart';
import '../interactor/inventory_state.dart';
import '../../auth/interactor/auth_bloc.dart';
import '../../auth/interactor/auth_state.dart';
import '../../../domain/entities/user_profile.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InventoryBloc(repository: getIt<InventoryRepository>())
            ..add(LoadInventory()),
      child: const InventoryView(),
    );
  }
}

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  String? _selectedCategoryId; // null means "All"
  String? _stockFilter; // null = all, 'low' = low stock, 'out' = out of stock

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState.user?.role == UserRole.admin;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  final totalProducts = state.tshirts.length;
                  final lowStock = state.tshirts.where((tshirt) {
                    return tshirt.variants.any(
                      (v) => v.stockQuantity > 0 && v.stockQuantity < 10,
                    );
                  }).length;
                  final outOfStock = state.tshirts.where((tshirt) {
                    return tshirt.variants.isNotEmpty &&
                        tshirt.variants.every((v) => v.stockQuantity == 0);
                  }).length;

                  double totalValue = 0;
                  for (var tshirt in state.tshirts) {
                    final totalStock = tshirt.variants.fold<int>(
                      0,
                      (sum, v) => sum + v.stockQuantity,
                    );
                    totalValue += tshirt.basePrice * totalStock;
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = 4;
                      if (width < 600)
                        crossAxisCount = 1;
                      else if (width < 1000)
                        crossAxisCount = 2;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _stockFilter = null;
                                _selectedCategoryId = null;
                              });
                            },
                            child: StatCard(
                              title: 'Total Products',
                              value: '$totalProducts',
                              icon: Icons.inventory_2,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _stockFilter = _stockFilter == 'low'
                                    ? null
                                    : 'low';
                                _selectedCategoryId = null;
                              });
                            },
                            child: StatCard(
                              title: 'Low Stock',
                              value: '$lowStock',
                              badgeText: lowStock > 0
                                  ? 'Needs Attention'
                                  : null,
                              badgeColor: const Color(0xFFEAB308),
                              icon: Icons.warning,
                              iconColor: const Color(0xFFEAB308),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _stockFilter = _stockFilter == 'out'
                                    ? null
                                    : 'out';
                                _selectedCategoryId = null;
                              });
                            },
                            child: StatCard(
                              title: 'Out of Stock',
                              value: '$outOfStock',
                              badgeText: outOfStock > 0
                                  ? 'Restock needed'
                                  : null,
                              badgeColor: const Color(0xFF7676AC),
                              icon: Icons.error,
                              iconColor: Colors.red,
                            ),
                          ),
                          StatCard(
                            title: 'Total Value',
                            value: '\$${totalValue.toStringAsFixed(2)}',
                            icon: Icons.attach_money,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // Header & Action
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 600;
                  final headerContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Items',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D0D1B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your product catalog, variants, and stock levels.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF4C4C9A),
                        ),
                      ),
                    ],
                  );

                  final addButton = isAdmin
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            await context.push('/inventory/add');
                            if (context.mounted) {
                              context.read<InventoryBloc>().add(
                                LoadInventory(),
                              );
                            }
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add New T-shirt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1313EC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();

                  if (isDesktop) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [headerContent, addButton],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        headerContent,
                        const SizedBox(height: 16),
                        addButton,
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              // Filters
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE7E7F3)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        Widget buildFilterChips() {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = null;
                                    });
                                  },
                                  child: _FilterChip(
                                    label: 'All Categories',
                                    isSelected: _selectedCategoryId == null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ...state.categories.map((category) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryId = category.id;
                                        });
                                      },
                                      child: _FilterChip(
                                        label: category.name,
                                        isSelected:
                                            _selectedCategoryId == category.id,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }

                        if (constraints.maxWidth > 600) {
                          return Row(
                            children: [Expanded(child: buildFilterChips())],
                          );
                        } else {
                          return buildFilterChips();
                        }
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Grid
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  if (state.status == InventoryStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == InventoryStatus.failure) {
                    return Center(child: Text('Error: ${state.errorMessage}'));
                  }

                  var filteredTshirts = _selectedCategoryId == null
                      ? state.tshirts
                      : state.tshirts
                            .where((t) => t.categoryId == _selectedCategoryId)
                            .toList();

                  if (_stockFilter == 'low') {
                    filteredTshirts = filteredTshirts.where((tshirt) {
                      return tshirt.variants.any(
                        (v) => v.stockQuantity > 0 && v.stockQuantity < 10,
                      );
                    }).toList();
                  } else if (_stockFilter == 'out') {
                    filteredTshirts = filteredTshirts.where((tshirt) {
                      return tshirt.variants.isNotEmpty &&
                          tshirt.variants.every((v) => v.stockQuantity == 0);
                    }).toList();
                  }

                  if (filteredTshirts.isEmpty) {
                    return const Center(child: Text('No items found.'));
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          mainAxisExtent: 400,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: filteredTshirts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        tshirt: filteredTshirts[index],
                        onTap: isAdmin
                            ? () async {
                                await context.push(
                                  '/inventory/edit/${filteredTshirts[index].id}',
                                  extra: filteredTshirts[index],
                                );
                                if (context.mounted) {
                                  context.read<InventoryBloc>().add(
                                    LoadInventory(),
                                  );
                                }
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE7E7F3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? const Color(0xFF0D0D1B) : const Color(0xFF4C4C9A),
        ),
      ),
    );
  }
}
