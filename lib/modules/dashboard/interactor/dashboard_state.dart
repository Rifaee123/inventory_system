import 'package:equatable/equatable.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final double totalSales;
  final double netProfit;
  final int totalOrders;
  final List<double> weeklySales;
  final double taxLiability;
  final int itemsSold;
  final Map<String, double> categorySales;
  final Map<String, int> topSizes;
  final List<RecentOrder> recentActivity;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.totalSales = 0,
    this.netProfit = 0,
    this.totalOrders = 0,
    this.weeklySales = const [0, 0, 0, 0, 0, 0, 0],
    this.taxLiability = 0,
    this.itemsSold = 0,
    this.categorySales = const {},
    this.topSizes = const {},
    this.recentActivity = const [],
  });

  DashboardState copyWith({
    DashboardStatus? status,
    double? totalSales,
    double? netProfit,
    int? totalOrders,
    List<double>? weeklySales,
    double? taxLiability,
    int? itemsSold,
    Map<String, double>? categorySales,
    Map<String, int>? topSizes,
    List<RecentOrder>? recentActivity,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalSales: totalSales ?? this.totalSales,
      netProfit: netProfit ?? this.netProfit,
      totalOrders: totalOrders ?? this.totalOrders,
      weeklySales: weeklySales ?? this.weeklySales,
      taxLiability: taxLiability ?? this.taxLiability,
      itemsSold: itemsSold ?? this.itemsSold,
      categorySales: categorySales ?? this.categorySales,
      topSizes: topSizes ?? this.topSizes,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }

  @override
  List<Object?> get props => [
    status,
    totalSales,
    netProfit,
    totalOrders,
    weeklySales,
    taxLiability,
    itemsSold,
    categorySales,
    topSizes,
    recentActivity,
  ];
}

class RecentOrder extends Equatable {
  final String id;
  final String customerName;
  final DateTime date;
  final double amount;
  final String status;
  final String customerInitials;

  const RecentOrder({
    required this.id,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.status,
    required this.customerInitials,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    date,
    amount,
    status,
    customerInitials,
  ];
}
