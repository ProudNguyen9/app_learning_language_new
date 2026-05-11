import 'package:apphoctienganh/features/auth/presentation/screens/start_screen.dart';
import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ColorSetting.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorSetting.colorprimary,
          surface: ColorSetting.background,
          brightness: Brightness.light,
        ),
      ),
      home: const Start_Screen(),
    );
  }
}
