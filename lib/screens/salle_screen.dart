import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../handlers/room/salle_handler.dart';
import '../services/livekit_service.dart';
import '../widgets/common/app_colors.dart';
import '../widgets/common/app_message.dart';
import '../widgets/room/room_audio_visualizer.dart';
import '../widgets/room/room_controls.dart';
import '../widgets/room/room_header.dart';
import '../widgets/room/room_video.dart';
import 'home_screen.dart';

class SalleScreen extends StatefulWidget {
  const SalleScreen({super.key});

  @override
  State<SalleScreen> createState() => _SalleScreenState();
}

class _SalleScreenState extends State<SalleScreen> {
  late final ParticipantPresenceManager _participantPresenceManager;
  bool _isEnDirect = false;
  bool _isConnected = false;
  bool _cameraEnabled = false;
  bool _microphoneEnabled = false;
  bool _isFullscreen = false;
  bool _isLeaving = false;
  bool _updatingMedia = false;
  bool _requestingPermissions = false;
  double _audioLevel = 0;
  String? _roomName;
  String? _error;
  LocalVideoTrack? _localVideoTrack;
  RemoteVideoTrack? _remoteVideoTrack;
  RemoteAudioTrack? _remoteAudioTrack;
  DateTime? _lastVisualizerUpdate;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _participantPresenceManager =
        SalleHandler.createParticipantPresenceManager();
    unawaited(_prepareRoom());
  }

  Future<void> _prepareRoom() async {
    debugPrint('[SalleScreen] Préparation de la salle');
    await _requestInitialPermissions();
    if (mounted) await _initializeRoom();
  }

  Future<void> _requestInitialPermissions() async {
    if (_requestingPermissions) return;
    debugPrint('[SalleScreen] Demande des permissions caméra et microphone');
    setState(() => _requestingPermissions = true);
    final statuses = await [Permission.camera, Permission.microphone].request();
    if (!mounted) return;
    setState(() => _requestingPermissions = false);
    debugPrint(
      '[SalleScreen] Permissions — caméra: ${statuses[Permission.camera]}, microphone: ${statuses[Permission.microphone]}',
    );
    final permanentlyDenied = <String>[
      if (statuses[Permission.camera]?.isPermanentlyDenied ?? false) 'caméra',
      if (statuses[Permission.microphone]?.isPermanentlyDenied ?? false)
        'microphone',
    ];
    if (permanentlyDenied.isNotEmpty) {
      _showError(
        'Permission ${permanentlyDenied.join(' et ')} définitivement refusée. Ouvrez les paramètres de l’application pour l’autoriser.',
      );
    }
  }

  Future<bool> _ensurePermission(Permission permission, String feature) async {
    var status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showError(
        'Permission $feature définitivement refusée. Ouvrez les paramètres de l’application pour l’autoriser.',
      );
      return false;
    }
    if (_requestingPermissions) return false;
    setState(() => _requestingPermissions = true);
    status = await permission.request();
    if (!mounted) return false;
    setState(() => _requestingPermissions = false);
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showError(
        'Permission $feature définitivement refusée. Ouvrez les paramètres de l’application pour l’autoriser.',
      );
    } else {
      _showError('Permission $feature refusée.');
    }
    return false;
  }

  Future<void> _initializeRoom() => SalleHandler.initialize(
    participantPresenceManager: _participantPresenceManager,
    setIsEnDirect: (value) => _setIfMounted(() => _isEnDirect = value),
    setIsConnected: (value) => _setIfMounted(() => _isConnected = value),
    setCameraEnabled: (value) => _setIfMounted(() => _cameraEnabled = value),
    setRoomName: (value) => _setIfMounted(() => _roomName = value),
    setLocalVideoTrack: (value) =>
        _setIfMounted(() => _localVideoTrack = value),
    setMicrophoneEnabled: (value) =>
        _setIfMounted(() => _microphoneEnabled = value),
    setRemoteVideoTrack: (value) =>
        _setIfMounted(() => _remoteVideoTrack = value),
    setRemoteAudioTrack: _setRemoteAudioTrack,
  );

  void _setIfMounted(VoidCallback update) {
    if (mounted) setState(update);
  }

  void _setRemoteAudioTrack(RemoteAudioTrack? track) {
    if (!mounted) return;
    setState(() => _remoteAudioTrack = track);
    if (track == null) return;
    unawaited(track.start());
    LivekitService.analyzeAudio(track, (level) {
      final now = DateTime.now();
      if (!mounted ||
          (_lastVisualizerUpdate != null &&
              now.difference(_lastVisualizerUpdate!).inMilliseconds < 80)) {
        return;
      }
      _lastVisualizerUpdate = now;
      setState(() => _audioLevel = level);
    });
  }

  void _showError(String message) {
    _messageTimer?.cancel();
    setState(() => _error = message);
    debugPrint('[SalleScreen] Show error message : $message');
    _messageTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _error = null);
    });
  }

  Future<void> _toggleCamera() async {
    if (_updatingMedia) return;
    final nextState = !_cameraEnabled;
    if (nextState && !await _ensurePermission(Permission.camera, 'caméra')) {
      return;
    }
    if (!mounted) return;
    setState(() => _updatingMedia = true);
    final error = await SalleHandler.toggleCamera(etat: nextState);
    if (!mounted) return;
    setState(() => _updatingMedia = false);
    if (error != null) {
      _showError(error);
      return;
    }
    setState(() => _cameraEnabled = nextState);
  }

  Future<void> _toggleMicrophone() async {
    if (_updatingMedia) return;
    final nextState = !_microphoneEnabled;
    if (nextState &&
        !await _ensurePermission(Permission.microphone, 'microphone')) {
      return;
    }
    if (!mounted) return;
    setState(() => _updatingMedia = true);
    final error = await SalleHandler.toggleMicrophone(etat: nextState);
    if (!mounted) return;
    setState(() => _updatingMedia = false);
    if (error != null) {
      _showError(error);
      return;
    }
    setState(() => _microphoneEnabled = nextState);
  }

  Future<void> _leaveRoom() async {
    if (_isLeaving) return;
    debugPrint('[SalleScreen] Sortie de salle demandée');
    setState(() => _isLeaving = true);
    final left = await SalleHandler.quitterSalle(
      participantPresenceManager: _participantPresenceManager,
    );
    if (!mounted) return;
    if (!left) {
      setState(() => _isLeaving = false);
      _showError('Impossible de quitter la salle.');
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
    debugPrint('[SalleScreen] Navigation vers Home');
  }

  Future<void> _toggleFullscreen() async {
    final enteringFullscreen = !_isFullscreen;
    await SystemChrome.setEnabledSystemUIMode(
      enteringFullscreen
          ? SystemUiMode.immersiveSticky
          : SystemUiMode.edgeToEdge,
    );
    if (mounted) setState(() => _isFullscreen = enteringFullscreen);
    debugPrint('[SalleScreen] Plein écran: $enteringFullscreen');
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    unawaited(LivekitService.disconnect());
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localTrack = _cameraEnabled ? _localVideoTrack : null;
    return Semantics(
      label: _roomName == null ? 'Salle Alina' : 'Salle $_roomName',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.all(_isFullscreen ? 0 : 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isFullscreen ? 0 : 20),
                child: RoomVideo(
                  remoteTrack: _remoteVideoTrack,
                  localTrack: localTrack,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: RoomHeader(
                  isConnected: _isConnected,
                  isLive: _isEnDirect,
                  isFullscreen: _isFullscreen,
                  isLeaving: _isLeaving,
                  onFullscreenPressed: () => unawaited(_toggleFullscreen()),
                  onLeavePressed: () => unawaited(_leaveRoom()),
                ),
              ),
            ),
            if (_error != null)
              Positioned(
                top: 68,
                left: 16,
                right: 16,
                child: SafeArea(
                  top: !_isFullscreen,
                  bottom: false,
                  child: AppMessage(message: _error!),
                ),
              ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 18,
              child: SafeArea(
                top: false,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0),
                        AppColors.background.withValues(alpha: .92),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RoomAudioVisualizer(
                          level: _remoteAudioTrack == null ? 0 : _audioLevel,
                        ),
                        const SizedBox(height: 18),
                        RoomControls(
                          microphoneEnabled: _microphoneEnabled,
                          cameraEnabled: _cameraEnabled,
                          enabled:
                              !_updatingMedia &&
                              !_isLeaving &&
                              !_requestingPermissions,
                          onMicrophonePressed: () =>
                              unawaited(_toggleMicrophone()),
                          onCameraPressed: () => unawaited(_toggleCamera()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
