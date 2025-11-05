import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'state/generation_state.dart';
import 'theme/premium_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    ChangeNotifierProvider(
      create: (_) => GenerationState()..loadApiKey(),
      child: const IdeogramApp(),
    ),
  );
}

class IdeogramApp extends StatelessWidget {
  const IdeogramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ideogram Studio',
      debugShowCheckedModeBanner: false,
      theme: PremiumTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
