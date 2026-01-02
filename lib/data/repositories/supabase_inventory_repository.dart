import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tshirt.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/variant.dart';
import '../../domain/repositories/inventory_repository.dart';

class SupabaseInventoryRepository implements InventoryRepository {
  final SupabaseClient _client;

  SupabaseInventoryRepository(this._client);

  @override
  Future<void> addCategory(Category category) async {
    await _client.from('categories').insert({
      'name': category.name,
      'tax_percentage': category.taxPercentage,
    });
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List).map((e) => Category.fromJson(e)).toList();
  }

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
    print('Add Product Response: $response');

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
    // Update product fields
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

    // Delete all existing variants for this product
    await _client.from('variants').delete().eq('tshirt_id', tshirt.id);

    // Insert new variants
    if (tshirt.variants.isNotEmpty) {
      for (var variant in tshirt.variants) {
        await _client.from('variants').insert({
          'tshirt_id': tshirt.id,
          'size': variant.size,
          'color': variant.color,
          'stock_quantity': variant.stockQuantity,
        });
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

  @override
  Future<String> uploadImage(String filePath) async {
    final file = File(filePath);
    final fileName =
        '${DateTime.now().toIso8601String()}_${file.uri.pathSegments.last}';
    await _client.storage.from('products').upload(fileName, file);
    return _client.storage.from('products').getPublicUrl(fileName);
  }

  @override
  Future<Category> getOrCreateCategory(String name) async {
    // Check if exists (case-insensitive)
    final existingParams = await _client
        .from('categories')
        .select()
        .ilike('name', name)
        .maybeSingle();

    if (existingParams != null) {
      return Category.fromJson(existingParams);
    }

    // Create new
    final newParams = await _client
        .from('categories')
        .insert({
          'name': name,
          'tax_percentage': 0, // Default
        })
        .select()
        .single();

    return Category.fromJson(newParams);
  }
}
