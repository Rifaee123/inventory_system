import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_system/modules/dashboard/domain/repositories/dashboard_repository.dart';

import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final DashboardRepository _repository;

  AnalyticsBloc(this._repository) : super(const AnalyticsState()) {
    on<LoadAnalyticsData>(_onLoadAnalyticsData);
  }

  Future<void> _onLoadAnalyticsData(
    LoadAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    try {
      final stats = await _repository.getDashboardStats();
      final weeklySales = await _repository.getWeeklySales();
      final categorySales = await _repository.getCategorySales();
      final topSizes = await _repository.getTopSizes();
      final topProducts = await _repository.getTopProducts();

      emit(
        state.copyWith(
          status: AnalyticsStatus.success,
          stats: stats,
          weeklySales: weeklySales,
          categorySales: categorySales,
          topSizes: topSizes,
          topProducts: topProducts,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AnalyticsStatus.failure));
    }
  }
}
