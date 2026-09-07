import 'dart:async';

import 'package:flutter/material.dart';

import '../services/health_service.dart';
import '../services/session_service.dart';
import '../widgets/common/backend_connection_loader.dart';
import 'auth_screen.dart';

const _backendCheckRetryDelay = Duration(seconds: 2);
const _pendingDisconnectionsTimeout = Duration(seconds: 3);

class BackendStartupScreen extends StatefulWidget {
  const BackendStartupScreen({super.key});

  @override
  State<BackendStartupScreen> createState() => _BackendStartupScreenState();
}

class _BackendStartupScreenState extends State<BackendStartupScreen> {
  Timer? _retryTimer;
  bool _isBackendReady = false;
  bool _hasStartedSynchronization = false;

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
        _startSynchronizationAfterFirstAppFrame();
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

  void _startSynchronizationAfterFirstAppFrame() {
    if (_hasStartedSynchronization) return;

    _hasStartedSynchronization = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(_synchronizePendingDisconnections());
    });
  }

  Future<void> _synchronizePendingDisconnections() async {
    try {
      await SessionService.synchronizePendingDisconnections().timeout(
        _pendingDisconnectionsTimeout,
      );
    } catch (error) {
      debugPrint('[App] Synchronisation des deconnexions ignoree: $error');
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
