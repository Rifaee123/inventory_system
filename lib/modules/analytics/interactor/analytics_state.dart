import 'package:equatable/equatable.dart';

enum AnalyticsStatus { initial, loading, success, failure }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final Map<String, dynamic> stats;
  final List<double> weeklySales;
  final Map<String, double> categorySales;
  final Map<String, int> topSizes;
  final List<Map<String, dynamic>> topProducts;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.stats = const {},
    this.weeklySales = const [],
    this.categorySales = const {},
    this.topSizes = const {},
    this.topProducts = const [],
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    Map<String, dynamic>? stats,
    List<double>? weeklySales,
    Map<String, double>? categorySales,
    Map<String, int>? topSizes,
    List<Map<String, dynamic>>? topProducts,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      weeklySales: weeklySales ?? this.weeklySales,
      categorySales: categorySales ?? this.categorySales,
      topSizes: topSizes ?? this.topSizes,
      topProducts: topProducts ?? this.topProducts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stats,
    weeklySales,
    categorySales,
    topSizes,
    topProducts,
  ];
}
