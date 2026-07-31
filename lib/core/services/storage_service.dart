import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles uploading files to Supabase Storage.
/// This is the ONLY class allowed to call `Supabase.instance.client.storage`.
/// Feature repositories call into this shared service instead of each
/// duplicating upload logic themselves.
class StorageService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    await _supabaseClient.storage.from(bucket).uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return _supabaseClient.storage.from(bucket).getPublicUrl(path);
  }
}