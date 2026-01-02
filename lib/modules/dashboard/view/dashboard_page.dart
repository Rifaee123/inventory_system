import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../interactor/dashboard_bloc.dart';
import '../interactor/dashboard_event.dart';
import '../interactor/dashboard_state.dart';
import '../../../core/services/locator.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import 'analytics_graph.dart';
import 'dashboard_widgets.dart';
import '../../auth/interactor/auth_bloc.dart';
import '../../auth/interactor/auth_state.dart';
import '../../../domain/entities/user_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DashboardBloc(getIt<DashboardRepository>())
            ..add(LoadDashboardStats()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8), // background-light
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isAdmin = authState.user?.role == UserRole.admin;

          if (!isAdmin) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${authState.user?.username ?? "User"}',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dashboard analytics are restricted to administrators.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/inventory'),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Browse Products'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1313EC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.status == DashboardStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == DashboardStatus.failure) {
                return const Center(
                  child: Text('Failed to load dashboard data'),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Heading
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 800) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildHeaderTitle(context),
                              _buildHeaderActions(),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderTitle(context),
                              const SizedBox(height: 16),
                              _buildHeaderActions(),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    // Stats Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        int crossAxisCount = 1;
                        if (width > 1200)
                          crossAxisCount = 4;
                        else if (width > 800)
                          crossAxisCount = 2;

                        // Calculate item width
                        final double itemWidth =
                            (width - ((crossAxisCount - 1) * 16)) /
                            crossAxisCount;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: itemWidth,
                              child: DashboardStatCard(
                                title: 'Total Revenue',
                                value:
                                    '\$${state.totalSales.toStringAsFixed(0)}', // Rounded for cleaner look
                                icon: Icons.attach_money,
                                color: const Color(0xFF1313EC),
                                percentage: '12%',
                                isPositive: true,
                              ),
                            ),
                            SizedBox(
                              width: itemWidth,
                              child: DashboardStatCard(
                                title: 'Net Profit',
                                value:
                                    '\$${state.netProfit.toStringAsFixed(0)}',
                                icon: Icons.payments,
                                color: Colors.green,
                                percentage: '8%',
                                isPositive: true,
                              ),
                            ),
                            SizedBox(
                              width: itemWidth,
                              child: DashboardStatCard(
                                title: 'Tax Liability',
                                value:
                                    '\$${state.taxLiability.toStringAsFixed(0)}',
                                icon: Icons.receipt_long,
                                color: Colors.orange,
                                percentage: '2%',
                                isPositive:
                                    true, // Red in HTML but trend Up implies "increase" which is technically "bad" for tax but "positive number"
                              ),
                            ),
                            SizedBox(
                              width: itemWidth,
                              child: DashboardStatCard(
                                title: 'Items Sold',
                                value: state.itemsSold.toString(), // e.g. 3,420
                                icon: Icons.inventory_2,
                                color: Colors.blue,
                                percentage: '15%',
                                isPositive: true,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Main Chart Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 600;

                              Widget titleSection = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sales Performance',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Revenue over time',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              );

                              Widget filterTabs = Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildTab('Day', false),
                                    _buildTab('Week', false),
                                    _buildTab('Month', true), // Active
                                    _buildTab('Year', false),
                                  ],
                                ),
                              );

                              if (isMobile) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    titleSection,
                                    const SizedBox(height: 12),
                                    filterTabs,
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [titleSection, filterTabs],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: AnalyticsGraph(
                              weeklySales: state.weeklySales,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Split Section: Secondary Charts
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 900) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SalesCategoryChart(
                                  data: state.categorySales,
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                child: TopSizesList(data: state.topSizes),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              SalesCategoryChart(data: state.categorySales),
                              const SizedBox(height: 32),
                              TopSizesList(data: state.topSizes),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 32),

                    // Recent Orders Table
                    RecentOrdersTable(orders: state.recentActivity),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales & Financial Analytics',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A), // slate-900
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Real-time overview of your store's performance.",
          style: TextStyle(color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text('Export'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1313EC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            elevation: 4,
            shadowColor: const Color(0xFF1313EC).withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: isActive
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            )
          : null,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isActive ? const Color(0xFF1313EC) : Colors.grey[600],
        ),
      ),
    );
  }
}
