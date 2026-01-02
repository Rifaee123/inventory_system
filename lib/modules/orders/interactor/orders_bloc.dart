import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/order_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _orderRepository;

  OrdersBloc({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const OrdersState()) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrder>(_onUpdateOrder);
    on<DeleteOrder>(_onDeleteOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: OrdersStatus.loading));

    try {
      final statusFilter = event.statusFilter ?? state.selectedStatusFilter;
      final searchQuery = event.searchQuery ?? state.searchQuery;

      final orders = await _orderRepository.getOrders(
        statusFilter: statusFilter,
        searchQuery: searchQuery,
      );
      emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: orders,
          selectedStatusFilter: statusFilter,
          searchQuery: searchQuery,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await _orderRepository.createOrder(event.order);
      // Reload orders after creating
      add(LoadOrders(statusFilter: state.selectedStatusFilter));
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateOrder(
    UpdateOrder event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await _orderRepository.updateOrder(event.order);
      // Reload orders after updating
      add(LoadOrders(statusFilter: state.selectedStatusFilter));
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrder event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await _orderRepository.deleteOrder(event.orderId);
      // Reload orders after deleting
      add(LoadOrders(statusFilter: state.selectedStatusFilter));
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await _orderRepository.updateOrderStatus(event.orderId, event.newStatus);
      // Reload orders after updating status
      add(LoadOrders(statusFilter: state.selectedStatusFilter));
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
