import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'features/auth/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: HomeScreen(), // Temporary placeholder for the logged-in area of the app.
    );
  }
}