import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth_screen.dart';
import 'services/session_service.dart';
import 'widgets/common/app_colors.dart';

Future<void> main() async {
  debugPrint('[App] Démarrage de l’application');
  await dotenv.load(fileName: ".env");
  debugPrint('[App] Configuration chargée');

  unawaited(
    SessionService.synchronizePendingDisconnections()
        .timeout(const Duration(seconds: 3))
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('[App] Synchronisation des deconnexions ignoree: $error');
        }),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alina',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'sans-serif',
        colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface, onSurface: AppColors.textPrimary),
      ),
      home: const AuthScreen(),
    );
  }
}
