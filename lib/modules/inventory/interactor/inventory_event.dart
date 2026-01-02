import 'package:equatable/equatable.dart';
import '../../../../domain/entities/tshirt.dart';
import '../../../../domain/entities/category.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddTShirt extends InventoryEvent {
  final TShirt tshirt;
  const AddTShirt(this.tshirt);

  @override
  List<Object?> get props => [tshirt];
}

class UpdateTShirt extends InventoryEvent {
  final TShirt tshirt;
  const UpdateTShirt(this.tshirt);

  @override
  List<Object?> get props => [tshirt];
}

class DeleteTShirt extends InventoryEvent {
  final String id;
  const DeleteTShirt(this.id);

  @override
  List<Object?> get props => [id];
}

class AddCategory extends InventoryEvent {
  final Category category;
  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class AddTShirtWithCategoryName extends InventoryEvent {
  final TShirt tshirt;
  final String categoryName;
  const AddTShirtWithCategoryName(this.tshirt, this.categoryName);

  @override
  List<Object?> get props => [tshirt, categoryName];
}

class UpdateTShirtWithCategoryName extends InventoryEvent {
  final TShirt tshirt;
  final String categoryName;
  const UpdateTShirtWithCategoryName(this.tshirt, this.categoryName);

  @override
  List<Object?> get props => [tshirt, categoryName];
}
