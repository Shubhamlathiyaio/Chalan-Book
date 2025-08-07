import 'dart:io';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class Supa {
  final SupabaseClient _client;
  SupabaseStorageClient get storage => _client.storage;
  Supa() : _client = SupabaseClient(AppKeys.supabaseUrl, AppKeys.supabaseAnonKey);

  Future<String?> setImageAndGetUrl({
    required File imageFile,
    String bucketName = AppKeys.chalanImagesBucket,
  }) async {
    try {
      final fileName = '${const Uuid().v4()}.jpg';

      await storage.from(bucketName).upload(fileName, imageFile);

      final publicUrl = storage.from(bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }
}
