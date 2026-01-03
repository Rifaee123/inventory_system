import '../entities/tshirt.dart';
import '../entities/variant.dart';

abstract class InventoryRepository {
  Future<List<TShirt>> getTShirts();
  Future<TShirt> getTShirt(String id);
  Future<void> addTShirt(TShirt tshirt);
  Future<void> updateTShirt(TShirt tshirt);
  Future<void> deleteTShirt(String id);
  Future<void> addVariant(Variant variant);
  Future<void> updateVariant(Variant variant);
  Future<void> deleteVariant(String id);
}
