import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

import '../../../../domain/entities/category.dart';
import '../../../../domain/entities/tshirt.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;

  InventoryBloc({required InventoryRepository repository})
    : _repository = repository,
      super(const InventoryState()) {
    on<LoadInventory>(_onLoadInventory);
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
      var categories = await _repository.getCategories();

      // Auto-seed required categories if missing
      final requiredCategories = ['Oversized', 'Old Money Outfit'];
      bool addedNew = false;

      for (final name in requiredCategories) {
        if (!categories.any((c) => c.name == name)) {
          try {
            await _repository.addCategory(
              Category(id: '', name: name, taxPercentage: 0),
            );
            addedNew = true;
          } catch (_) {
            // Ignore duplication errors if parallel runs occur
          }
        }
      }

      if (addedNew) {
        categories = await _repository.getCategories();
      }

      final tshirts = await _repository.getTShirts();
      emit(
        state.copyWith(
          status: InventoryStatus.success,
          categories: categories,
          tshirts: tshirts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
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
      final category = await _repository.getOrCreateCategory(
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
      final category = await _repository.getOrCreateCategory(
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
      await _repository.addCategory(event.category);
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
