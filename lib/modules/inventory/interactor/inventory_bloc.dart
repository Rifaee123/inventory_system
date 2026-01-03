import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/repositories/inventory_repository.dart';
import '../domain/repositories/category_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

import '../domain/entities/tshirt.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;
  final CategoryRepository _categoryRepository;

  InventoryBloc({
    required InventoryRepository repository,
    required CategoryRepository categoryRepository,
  }) : _repository = repository,
       _categoryRepository = categoryRepository,
       super(const InventoryState()) {
    on<LoadInventory>(_onLoadInventory);
    on<FilterInventory>(_onFilterInventory);
    on<AddTShirt>(_onAddTShirt);
    on<UpdateTShirt>(_onUpdateTShirt);
    on<DeleteTShirt>(_onDeleteTShirt);
    on<AddCategory>(_onAddCategory);
    on<AddTShirtWithCategoryName>(_onAddTShirtWithCategoryName);
    on<UpdateTShirtWithCategoryName>(_onUpdateTShirtWithCategoryName);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      final categories = await _categoryRepository.getCategories();
      final tshirts = await _repository.getTShirts();

      final filteredState = _applyFiltersAndStats(
        state.copyWith(
          status: InventoryStatus.success,
          categories: categories,
          tshirts: tshirts,
        ),
      );

      emit(filteredState);
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onFilterInventory(FilterInventory event, Emitter<InventoryState> emit) {
    if (state.status != InventoryStatus.success) return;

    final newState = state.copyWith(
      selectedCategoryId: event.categoryId, // Pass null to reset
      stockFilter: event.stockFilter, // Pass null to reset
    );

    emit(_applyFiltersAndStats(newState));
  }

  InventoryState _applyFiltersAndStats(InventoryState currentState) {
    List<TShirt> filtered = currentState.tshirts;

    // Apply Category Filter
    if (currentState.selectedCategoryId != null) {
      filtered = filtered
          .where((t) => t.categoryId == currentState.selectedCategoryId)
          .toList();
    }

    // Apply Stock Filter
    if (currentState.stockFilter == 'low') {
      filtered = filtered.where((tshirt) {
        return tshirt.variants.any(
          (v) => v.stockQuantity > 0 && v.stockQuantity < 10,
        );
      }).toList();
    } else if (currentState.stockFilter == 'out') {
      filtered = filtered.where((tshirt) {
        return tshirt.variants.isNotEmpty &&
            tshirt.variants.every((v) => v.stockQuantity == 0);
      }).toList();
    }

    // Calculate Stats (on ALL items, or filtered items? Usually stats card shows Global stats, but List below shows filtered.
    // Based on the UI, the stats cards were responsive to filters in the previous implementation?
    // Checked previous UI: "Total Products = state.tshirts.length". So global.
    // "Low Stock" = global. "Out of Stock" = global.
    // So stats are calculating on ALL tshirts.

    final lowStock = currentState.tshirts.where((tshirt) {
      return tshirt.variants.any(
        (v) => v.stockQuantity > 0 && v.stockQuantity < 10,
      );
    }).length;

    final outOfStock = currentState.tshirts.where((tshirt) {
      return tshirt.variants.isNotEmpty &&
          tshirt.variants.every((v) => v.stockQuantity == 0);
    }).length;

    double totalValue = 0;
    for (var tshirt in currentState.tshirts) {
      final totalStock = tshirt.variants.fold<int>(
        0,
        (sum, v) => sum + v.stockQuantity,
      );
      totalValue += tshirt.basePrice * totalStock;
    }

    return currentState.copyWith(
      filteredTshirts: filtered,
      totalProducts: currentState.tshirts.length,
      lowStockCount: lowStock,
      outOfStockCount: outOfStock,
      totalValue: totalValue,
    );
  }

  Future<void> _onAddTShirt(
    AddTShirt event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _repository.addTShirt(event.tshirt);
      add(LoadInventory());
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddTShirtWithCategoryName(
    AddTShirtWithCategoryName event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final category = await _categoryRepository.getOrCreateCategory(
        event.categoryName,
      );
      final newTShirt = TShirt(
        id: event.tshirt.id,
        name: event.tshirt.name,
        description: event.tshirt.description,
        categoryId: category.id,
        imageUrl: event.tshirt.imageUrl,
        basePrice: event.tshirt.basePrice,
        offerPrice: event.tshirt.offerPrice,
        returnPolicyDays: event.tshirt.returnPolicyDays,
        priorityWeight: event.tshirt.priorityWeight,
        isActive: event.tshirt.isActive,
        variants: event.tshirt.variants,
      );
      await _repository.addTShirt(newTShirt);
      add(LoadInventory());
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateTShirt(
    UpdateTShirt event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _repository.updateTShirt(event.tshirt);
      add(LoadInventory());
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateTShirtWithCategoryName(
    UpdateTShirtWithCategoryName event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final category = await _categoryRepository.getOrCreateCategory(
        event.categoryName,
      );
      final updatedTShirt = TShirt(
        id: event.tshirt.id,
        name: event.tshirt.name,
        description: event.tshirt.description,
        categoryId: category.id,
        imageUrl: event.tshirt.imageUrl,
        basePrice: event.tshirt.basePrice,
        offerPrice: event.tshirt.offerPrice,
        returnPolicyDays: event.tshirt.returnPolicyDays,
        priorityWeight: event.tshirt.priorityWeight,
        isActive: event.tshirt.isActive,
        variants: event.tshirt.variants,
      );
      await _repository.updateTShirt(updatedTShirt);
      add(LoadInventory());
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteTShirt(
    DeleteTShirt event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _repository.deleteTShirt(event.id);
      add(LoadInventory());
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await _categoryRepository.addCategory(event.category);
      add(LoadInventory());
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
