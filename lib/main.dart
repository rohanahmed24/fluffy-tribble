import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'state/generation_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapEnvironment();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GenerationState()..loadApiKey(),
      child: const IdeogramApp(),
    ),
  );
}

Future<void> _bootstrapEnvironment() async {
  try {
    await dotenv.load(fileName: '.env');
    return;
  } on FlutterError catch (error) {
    debugPrint('Failed to load .env asset: ${error.message}');
  } on FileSystemException catch (error) {
    debugPrint('Failed to read .env file: ${error.message}');
  }

  if (!dotenv.isInitialized) {
    try {
      await dotenv.load(fileName: '.env.example');
    } on FlutterError catch (error) {
      debugPrint('Failed to load .env.example asset: ${error.message}');
    } on FileSystemException catch (error) {
      debugPrint('Failed to read .env.example file: ${error.message}');
    }
  }
}

class IdeogramApp extends StatelessWidget {
  const IdeogramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ideogram Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
