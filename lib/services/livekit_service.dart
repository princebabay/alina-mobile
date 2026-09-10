import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livekit_client/livekit_client.dart';

class LivekitService {
  static final String apiUrl = dotenv.env['API_URL']!;
  static final String serverUrl = dotenv.env['VITE_LIVEKIT_URL']!;
  static Room? room;
  static final List<CancelListenFunc> _roomEventSubscriptions = [];

  static Room? getRoom() {
    return room;
  }

  static Future<Room> connect({required String token}) async {
    if (room != null) {
      await disconnect();
    }

    debugPrint('[LivekitService] Connexion à la room');
    room = Room();
    await room!.connect(serverUrl, token);
    debugPrint('[LivekitService] Room connectée: ${room!.name}');
    return room!;
  }

  static Future<void> disconnect() async {
    debugPrint('[LivekitService] Déconnexion de la room');
    final currentRoom = room;

    await _cancelRoomEventSubscriptions();

    try {
      await currentRoom?.disconnect();
    } finally {
      try {
        await currentRoom?.dispose();
      } finally {
        if (identical(room, currentRoom)) {
          room = null;
        }
      }
    }
    debugPrint('[LivekitService] Room déconnectée');
  }

  static Future<void> _cancelRoomEventSubscriptions() async {
    final subscriptions = List<CancelListenFunc>.from(_roomEventSubscriptions);
    _roomEventSubscriptions.clear();

    await Future.wait(subscriptions.map((unsubscribe) => unsubscribe()));
  }

  static Future<void> enableCamera() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setCameraEnabled(true);
    debugPrint('[LivekitService] Caméra activée');
  }

  static Future<void> disableCamera() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setCameraEnabled(false);
    debugPrint('[LivekitService] Caméra désactivée');
  }

  static Future<void> enableMicrophone() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setMicrophoneEnabled(true);
    debugPrint('[LivekitService] Microphone activé');
  }

  static Future<void> disableMicrophone() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setMicrophoneEnabled(false);
    debugPrint('[LivekitService] Microphone désactivé');
  }

  static LocalVideoTrack? getCameraTrack() {
    if (room == null) {
      return null;
    }

    final publications = room!.localParticipant!.getTrackPublications();

    for (final publication in publications) {
      if (publication.source == TrackSource.camera) {
        final track = publication.track;

        if (track != null && track.kind == TrackType.VIDEO) {
          return track as LocalVideoTrack;
        }
      }
    }

    return null;
  }

  static void onRemoteAudioTrack(
    void Function(RemoteAudioTrack track) callback,
  ) {
    if (room == null) {
      return;
    }

    _roomEventSubscriptions.add(
      room!.events.listen((event) {
        if (event is TrackSubscribedEvent) {
          final track = event.track;

          if (track.kind == TrackType.AUDIO) {
            callback(track as RemoteAudioTrack);
          }
        }
      }),
    );

    room!.remoteParticipants.forEach((_, participant) {
      participant.trackPublications.forEach((_, publication) {
        final track = publication.track;

        if (track != null && track.kind == TrackType.AUDIO) {
          callback(track as RemoteAudioTrack);
        }
      });
    });
  }

  static void onRemoteVideoTrack(
    void Function(RemoteVideoTrack track) callback,
  ) {
    if (room == null) {
      return;
    }

    _roomEventSubscriptions.add(
      room!.events.listen((event) {
        if (event is TrackSubscribedEvent) {
          final track = event.track;

          if (track.kind == TrackType.VIDEO) {
            callback(track as RemoteVideoTrack);
          }
        }
      }),
    );

    room!.remoteParticipants.forEach((_, participant) {
      participant.trackPublications.forEach((_, publication) {
        final track = publication.track;

        if (track != null && track.kind == TrackType.VIDEO) {
          callback(track as RemoteVideoTrack);
        }
      });
    });
  }

  static void isEnDirectCall(void Function(bool etat) callback) {
    if (room == null) {
      return;
    }

    _roomEventSubscriptions.add(
      room!.events.listen((event) {
        if (event is ParticipantConnectedEvent) {
          debugPrint('[LivekitService] Participant distant connecté');
          callback(true);
        }

        if (event is ParticipantDisconnectedEvent) {
          debugPrint('[LivekitService] Participant distant déconnecté');
          callback(false);
        }
      }),
    );

    if (room!.remoteParticipants.isNotEmpty) {
      callback(true);
    }
  }

  static void onConnectionStateChange({
    required void Function() onReconnecting,
    required void Function() onReconnected,
    required void Function() onDisconnected,
  }) {
    if (room == null) {
      return;
    }

    _roomEventSubscriptions.add(
      room!.events.listen((event) {
        if (event is RoomReconnectingEvent ||
            event is RoomResumingEvent ||
            event is RoomAttemptReconnectEvent) {
          debugPrint('[LivekitService] Room en reconnexion');
          onReconnecting();
        }

        if (event is RoomReconnectedEvent || event is RoomConnectedEvent) {
          debugPrint('[LivekitService] Room reconnectée');
          onReconnected();
        }

        if (event is RoomDisconnectedEvent) {
          debugPrint('[LivekitService] Room déconnectée');
          onDisconnected();
        }
      }),
    );
  }

  static void analyzeAudio(
    RemoteAudioTrack track,
    void Function(double level) callback,
  ) {
    track.addAudioRenderer(
      onFrame: (frame) {
        final samples = frame.data.buffer.asInt16List(
          frame.data.offsetInBytes,
          frame.data.lengthInBytes ~/ 2,
        );
        double sumSquares = 0;
        for (final s in samples) {
          sumSquares += s * s;
        }
        final rms = sqrt(sumSquares / samples.length) / 32768;
        final level = (rms * 100).clamp(0.0, 100.0);

        callback(level);
      },
    );
  }
}
