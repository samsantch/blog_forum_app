import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles uploading files to Supabase Storage.
/// This is the ONLY class allowed to call `Supabase.instance.client.storage`.
/// Feature repositories call into this shared service instead of each
/// duplicating upload logic themselves.
class StorageService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  static String extensionOf(XFile file) {
    final name = file.name;
    final dot = name.lastIndexOf('.');
    if (dot != -1 && dot < name.length - 1) {
      return name.substring(dot + 1).toLowerCase();
    }
    final mime = file.mimeType;
    if (mime != null && mime.contains('/')) {
      return mime.split('/').last.toLowerCase();
    }
    return 'jpg';
  }


  static String contentTypeOf(XFile file) {
    final mime = file.mimeType;
    if (mime != null && mime.isNotEmpty) return mime;
    return 'image/${extensionOf(file)}';
  }

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