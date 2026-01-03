import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class SupabaseCategoryRepository implements CategoryRepository {
  final SupabaseClient _client;

  SupabaseCategoryRepository(this._client);

  @override
  Future<List<Category>> getCategories() async {
    final response = await _client.from('categories').select();
    return (response as List).map((e) => Category.fromJson(e)).toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    await _client.from('categories').insert({
      'name': category.name,
      'tax_percentage': category.taxPercentage,
    });
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
