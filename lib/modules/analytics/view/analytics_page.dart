import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/locator.dart';
import '../../dashboard/domain/repositories/dashboard_repository.dart';
import '../../dashboard/view/analytics_graph.dart';
import '../../dashboard/view/dashboard_widgets.dart';
import '../interactor/analytics_bloc.dart';
import '../interactor/analytics_event.dart';
import '../interactor/analytics_state.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AnalyticsBloc(getIt<DashboardRepository>())..add(LoadAnalyticsData()),
      child: const AnalyticsView(),
    );
  }
}

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AnalyticsStatus.failure) {
            return const Center(child: Text('Failed to load analytics'));
          }

          final stats = state.stats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deep Analytics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Detailed breakdown of your store performance.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Advanced Stats Grid
                _buildAdvancedStats(stats),

                const SizedBox(height: 32),

                // Sales Trend
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revenue Trend (7D)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 300,
                        child: AnalyticsGraph(weeklySales: state.weeklySales),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Distribution Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SalesCategoryChart(data: state.categorySales),
                    ),
                    const SizedBox(width: 32),
                    Expanded(child: TopSizesList(data: state.topSizes)),
                  ],
                ),

                const SizedBox(height: 32),

                // NEW: Most Ordered Products
                _buildTopProducts(state.topProducts),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedStats(Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              title: 'Total Revenue',
              value: '\$${(stats['totalSales'] ?? 0).toStringAsFixed(2)}',
              icon: Icons.monetization_on,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Net Profit',
              value: '\$${(stats['netProfit'] ?? 0).toStringAsFixed(2)}',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Avg. Order Value',
              value: '\$${_calcAvg(stats).toStringAsFixed(2)}',
              icon: Icons.shopping_bag,
              color: Colors.purple,
            ),
            _StatCard(
              title: 'Items Sold',
              value: '${stats['itemsSold'] ?? 0}',
              icon: Icons.check_circle,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  double _calcAvg(Map<String, dynamic> stats) {
    final total = (stats['totalSales'] ?? 0) as double;
    final count = (stats['totalOrders'] ?? 0) as int;
    if (count == 0) return 0;
    return total / count;
  }

  Widget _buildTopProducts(List<Map<String, dynamic>> products) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most Ordered Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (products.isEmpty)
            const Center(child: Text('No products sold yet'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      image: product['image_url'] != null
                          ? DecorationImage(
                              image: NetworkImage(product['image_url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: product['image_url'] == null
                        ? const Icon(Icons.shopping_bag, color: Colors.grey)
                        : null,
                  ),
                  title: Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${product['quantity']} units sold'),
                  trailing: Text(
                    '\$${(product['revenue'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1313EC),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
