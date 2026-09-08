import 'dart:async';

import 'package:flutter/material.dart';

import '../services/health_service.dart';
import '../widgets/common/backend_connection_loader.dart';
import 'auth_screen.dart';

const _backendCheckRetryDelay = Duration(seconds: 2);

class BackendStartupScreen extends StatefulWidget {
  const BackendStartupScreen({super.key});

  @override
  State<BackendStartupScreen> createState() => _BackendStartupScreenState();
}

class _BackendStartupScreenState extends State<BackendStartupScreen> {
  Timer? _retryTimer;
  bool _isBackendReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkBackend());
  }

  Future<void> _checkBackend() async {
    try {
      final response = await HealthService.checkBackendHealth();

      if (response.success) {
        if (!mounted) return;

        setState(() => _isBackendReady = true);
        return;
      }
    } catch (_) {
      // HealthService journalise l'erreur avant que le retry soit planifié.
    }

    if (mounted) {
      _retryTimer = Timer(_backendCheckRetryDelay, () {
        unawaited(_checkBackend());
      });
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBackendReady) {
      return const BackendConnectionLoader();
    }

    return const AuthScreen();
  }
}
