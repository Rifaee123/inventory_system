import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tshirt.dart';
import '../../domain/entities/variant.dart';
import '../../domain/repositories/inventory_repository.dart';

class SupabaseInventoryRepository implements InventoryRepository {
  final SupabaseClient _client;

  SupabaseInventoryRepository(this._client);

  @override
  Future<List<TShirt>> getTShirts() async {
    final response = await _client
        .from('tshirts')
        .select('*, variants(*)')
        .order('created_at', ascending: false);
    return (response as List).map((e) => TShirt.fromJson(e)).toList();
  }

  @override
  Future<TShirt> getTShirt(String id) async {
    final response = await _client
        .from('tshirts')
        .select('*, variants(*)')
        .eq('id', id)
        .single();
    return TShirt.fromJson(response);
  }

  @override
  Future<void> addTShirt(TShirt tshirt) async {
    final response = await _client
        .from('tshirts')
        .insert({
          'name': tshirt.name,
          'description': tshirt.description,
          'category_id': tshirt.categoryId,
          'image_url': tshirt.imageUrl,
          'base_price': tshirt.basePrice,
          'offer_price': tshirt.offerPrice,
          'return_policy_days': tshirt.returnPolicyDays,
          'priority_weight': tshirt.priorityWeight,
          'is_active': tshirt.isActive,
        })
        .select()
        .single();

    // If there are variants, add them
    if (tshirt.variants.isNotEmpty) {
      final tshirtId = response['id'];
      for (var variant in tshirt.variants) {
        await _client.from('variants').insert({
          'tshirt_id': tshirtId,
          'size': variant.size,
          'color': variant.color,
          'stock_quantity': variant.stockQuantity,
        });
      }
    }
  }

  @override
  Future<void> updateTShirt(TShirt tshirt) async {
    // 1. Update product fields
    await _client
        .from('tshirts')
        .update({
          'name': tshirt.name,
          'description': tshirt.description,
          'category_id': tshirt.categoryId,
          'image_url': tshirt.imageUrl,
          'base_price': tshirt.basePrice,
          'offer_price': tshirt.offerPrice,
          'return_policy_days': tshirt.returnPolicyDays,
          'priority_weight': tshirt.priorityWeight,
          'is_active': tshirt.isActive,
        })
        .eq('id', tshirt.id);

    // 2. Fetch existing variant IDs to determine which ones to delete
    final existingVariantsResponse = await _client
        .from('variants')
        .select('id')
        .eq('tshirt_id', tshirt.id);
    final existingIds = (existingVariantsResponse as List)
        .map((e) => e['id'] as String)
        .toSet();

    final incomingIds = <String>{};

    // 3. Process incoming variants (Update or Insert)
    if (tshirt.variants.isNotEmpty) {
      for (var variant in tshirt.variants) {
        if (variant.id.isNotEmpty && existingIds.contains(variant.id)) {
          // Update existing
          incomingIds.add(variant.id);
          await _client
              .from('variants')
              .update({
                'size': variant.size,
                'color': variant.color,
                'stock_quantity': variant.stockQuantity,
              })
              .eq('id', variant.id);
        } else {
          // Insert new
          await _client.from('variants').insert({
            'tshirt_id': tshirt.id,
            'size': variant.size,
            'color': variant.color,
            'stock_quantity': variant.stockQuantity,
          });
        }
      }
    }

    // 4. Delete removed variants (Handle FK Constraints)
    final idsToDelete = existingIds.difference(incomingIds);
    for (var id in idsToDelete) {
      try {
        await _client.from('variants').delete().eq('id', id);
      } catch (e) {
        // If delete fails (likely FK constraint due to existing orders),
        // set stock to 0 to effectively "archive" it from availability.
        print(
          'Could not delete variant $id (likely used in orders). Setting stock to 0. Error: $e',
        );
        await _client
            .from('variants')
            .update({'stock_quantity': 0})
            .eq('id', id);
      }
    }
  }

  @override
  Future<void> deleteTShirt(String id) async {
    await _client.from('tshirts').delete().eq('id', id);
  }

  @override
  Future<void> addVariant(Variant variant) async {
    await _client.from('variants').insert(variant.toJson()..remove('id'));
  }

  @override
  Future<void> updateVariant(Variant variant) async {
    await _client
        .from('variants')
        .update(
          variant.toJson()
            ..remove('id')
            ..remove('tshirt_id'),
        )
        .eq('id', variant.id);
  }

  @override
  Future<void> deleteVariant(String id) async {
    await _client.from('variants').delete().eq('id', id);
  }
}
