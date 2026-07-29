import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles one-time initialization of the Supabase client.
///
/// This is the ONLY file in the entire app allowed to call
/// `Supabase.initialize`. Every other layer (data/logic/presentation)
/// must access Supabase through `Supabase.instance.client` inside
/// a feature's `data/` folder — never here, and never directly in UI.
class SupabaseConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    );
  }
}