import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../interactor/dashboard_state.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color; // The "theme" color for this card (icon bg, etc)
  final String percentage;
  final bool isPositive;
  final String subText;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.percentage,
    this.isPositive = true,
    this.subText = 'vs last month',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      percentage,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subText,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SalesCategoryChart extends StatelessWidget {
  final Map<String, double> data;

  const SalesCategoryChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales by Category',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Chart + Legend
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 400) {
                return Row(
                  children: [
                    _buildChart(),
                    const SizedBox(width: 32),
                    Expanded(child: _buildLegend()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildChart(),
                    const SizedBox(height: 24),
                    _buildLegend(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final List<Color> colors = [
      const Color(0xFF1313EC),
      Colors.blue.shade400,
      Colors.grey.shade300,
    ];

    int i = 0;
    List<PieChartSectionData> sections = [];
    data.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: value,
          title: '', // Hide title on chart
          radius: 20, // Thin donut
        ),
      );
      i++;
    });

    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 60,
              sectionsSpace: 0,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${data.values.fold(0.0, (p, c) => p + c).toInt()}', // Total Revenue
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total Rev.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final List<Color> colors = [
      const Color(0xFF1313EC), // Primary
      Colors.blue.shade400,
      Colors.grey.shade300,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.entries.map((e) {
        int index = data.keys.toList().indexOf(e.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.key,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Text(
                '\$${e.value.toStringAsFixed(0)}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class TopSizesList extends StatelessWidget {
  final Map<String, int> data;

  const TopSizesList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    int maxVal = data.values.fold(0, (p, c) => c > p ? c : p);
    if (maxVal == 0) maxVal = 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Selling Sizes',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...data.entries.map((e) {
            double percent = e.value / maxVal;
            // Opacity trick for color variation
            double opacity = 1.0 - (data.keys.toList().indexOf(e.key) * 0.2);
            if (opacity < 0.2) opacity = 0.2;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        resolveSizeName(e.key),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '${e.value} sold',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1313EC).withOpacity(opacity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String resolveSizeName(String key) {
    switch (key) {
      case 'L':
        return 'Large (L)';
      case 'M':
        return 'Medium (M)';
      case 'XL':
        return 'Extra Large (XL)';
      case 'S':
        return 'Small (S)';
      default:
        return key;
    }
  }
}

class RecentOrdersTable extends StatelessWidget {
  final List<RecentOrder> orders;

  const RecentOrdersTable({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF1313EC),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 24,
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              columns: const [
                DataColumn(
                  label: Text(
                    'Order ID',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Customer',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Action',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              rows: orders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        order.id,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _getAvatarColor(
                              order.customerInitials,
                            ),
                            child: Text(
                              order.customerInitials,
                              style: TextStyle(
                                color: _getAvatarTextColor(
                                  order.customerInitials,
                                ),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(order.customerName),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat('MMM dd, yyyy').format(order.date),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    DataCell(
                      Text(
                        '\$${order.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(_buildStatusBadge(order.status)),
                    const DataCell(Icon(Icons.more_vert, color: Colors.grey)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String initials) {
    if (initials.isEmpty) return Colors.grey.shade100;
    final int code = initials.codeUnits.fold(0, (p, c) => p + c);
    final List<Color> colors = [
      Colors.indigo.shade100,
      Colors.pink.shade100,
      Colors.orange.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.blue.shade100,
      Colors.teal.shade100,
    ];
    return colors[code % colors.length];
  }

  Color _getAvatarTextColor(String initials) {
    if (initials.isEmpty) return Colors.grey.shade700;
    final int code = initials.codeUnits.fold(0, (p, c) => p + c);
    final List<Color> colors = [
      Colors.indigo.shade700,
      Colors.pink.shade700,
      Colors.orange.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.blue.shade700,
      Colors.teal.shade700,
    ];
    return colors[code % colors.length];
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;

    if (status == 'Delivered') {
      bg = Colors.green.shade50;
      text = Colors.green.shade700;
    } else if (status == 'Shipped' || status == 'Dispatched') {
      bg = Colors.blue.shade50;
      text = Colors.blue.shade700;
    } else if (status == 'Cancelled') {
      bg = Colors.red.shade50;
      text = Colors.red.shade700;
    } else {
      bg = Colors.amber.shade50;
      text = Colors.amber.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
