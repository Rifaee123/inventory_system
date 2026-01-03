import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StorageService {
  Future<String> uploadImage(String filePath);
}

class SupabaseStorageService implements StorageService {
  final SupabaseClient _client;

  SupabaseStorageService(this._client);

  @override
  Future<String> uploadImage(String filePath) async {
    final file = File(filePath);
    final fileName =
        '${DateTime.now().toIso8601String()}_${file.uri.pathSegments.last}';
    await _client.storage.from('products').upload(fileName, file);
    return _client.storage.from('products').getPublicUrl(fileName);
  }
}
