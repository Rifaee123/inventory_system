import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsGraph extends StatelessWidget {
  final List<double> weeklySales;

  const AnalyticsGraph({super.key, required this.weeklySales});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          color: Theme.of(context).cardColor,
        ),
        child: LineChart(mainData(context)),
      ),
    );
  }

  LineChartData mainData(BuildContext context) {
    double maxSale = 0;
    for (var sale in weeklySales) {
      if (sale > maxSale) maxSale = sale;
    }

    // Default to at least $100 for the scale if no sales
    if (maxSale < 100) maxSale = 100;

    // Add 20% breathing room
    double maxY = maxSale * 1.2;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(value, meta, maxY),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            weeklySales.length,
            (index) => FlSpot(index.toDouble(), weeklySales[index]),
          ),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1313EC),
              const Color(0xFF1313EC).withOpacity(0.5),
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1313EC).withOpacity(0.2),
                const Color(0xFF1313EC).withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    // We want to show labels for the last 7 days ending TODAY at index 6
    final now = DateTime.now();
    final dayShift = 6 - value.toInt();
    final dateForIndex = now.subtract(Duration(days: dayShift));
    final String label = DateFormat('E').format(dateForIndex);

    // Only show 3-4 labels to avoid clutter
    if (value.toInt() % 2 != 0) return Container();

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double maxY) {
    if (value == 0) return Container();

    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      text = value.toInt().toString();
    }

    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 10,
        color: Colors.grey,
      ),
      textAlign: TextAlign.left,
    );
  }
}
