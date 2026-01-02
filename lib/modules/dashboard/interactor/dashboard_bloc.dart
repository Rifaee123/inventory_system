import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final stats = await _repository.getDashboardStats();
      final weeklySales = await _repository.getWeeklySales();
      final categorySales = await _repository.getCategorySales();
      final topSizes = await _repository.getTopSizes();
      final recentOrdersList = await _repository.getRecentOrders();

      final recentActivity = recentOrdersList.map((order) {
        return RecentOrder(
          id: '#${order.id.substring(0, 8).toUpperCase()}',
          customerName: order.customerName,
          customerInitials: _getInitials(order.customerName),
          date: order.createdAt,
          amount: order.totalAmount,
          status: order.status[0].toUpperCase() + order.status.substring(1),
        );
      }).toList();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          totalSales: (stats['totalSales'] as num).toDouble(),
          netProfit: (stats['netProfit'] as num).toDouble(),
          totalOrders: stats['totalOrders'] as int,
          weeklySales: weeklySales,
          taxLiability: (stats['taxLiability'] as num).toDouble(),
          itemsSold: stats['itemsSold'] as int,
          categorySales: categorySales,
          topSizes: topSizes,
          recentActivity: recentActivity,
        ),
      );
    } catch (e) {
      print('Dashboard Error: $e');
      emit(state.copyWith(status: DashboardStatus.failure));
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
