import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/desktop_home_screen.dart';
import 'state/generation_state.dart';
import 'theme/premium_theme.dart';
import 'theme/desktop_theme.dart';
import 'utils/platform_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    ChangeNotifierProvider(
      create: (_) => GenerationState()..loadApiKey(),
      child: const RogenApp(),
    ),
  );
}

class RogenApp extends StatelessWidget {
  const RogenApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use gorgeous desktop theme for Windows, macOS, Linux
    // Use mobile-optimized theme for Android, iOS, Web
    final theme = PlatformHelper.isDesktop
        ? DesktopTheme.darkTheme()
        : PremiumTheme.darkTheme;

    // Use gorgeous desktop layout for Windows, macOS, Linux
    // Use mobile layout for Android, iOS, Web
    final home = PlatformHelper.isDesktop
        ? const DesktopHomeScreen()
        : const HomeScreen();

    return MaterialApp(
      title: 'Rogen',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: home,
    );
  }
}
