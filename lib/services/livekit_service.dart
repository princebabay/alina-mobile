import 'dart:convert';

import 'package:alina_mobile/types/api.response.dart';
import 'package:alina_mobile/types/livekit.type.dart';
import 'package:alina_mobile/utils/request_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';

class LivekitService {
  static final String apiUrl = dotenv.env['API_URL']!;
  static final String serverUrl = dotenv.env['VITE_LIVEKIT_URL']!;
  static Room? room;

  static Room? getRoom() {
    return room;
  }

  static Future<ApiResponse<TokenResponse>> generateToken(
    TokenRequest data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/livekit/token'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);

      return ApiResponse.fromJson(
        json,
        (jsonData) => TokenResponse.fromJson(jsonData),
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<Room> connect({required String token}) async {
    room = Room();
    await room!.connect(serverUrl, token);
    return room!;
  }

  static Future<void> disconnect() async {
    await room?.disconnect();
    room = null;
  }

  static Future<void> enableCamera() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setCameraEnabled(true);
  }

  static Future<void> disableCamera() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setCameraEnabled(false);
  }

  static Future<void> enableMicrophone() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setMicrophoneEnabled(true);
  }

  static Future<void> disableMicrophone() async {
    if (room == null) {
      throw Exception("Non connecté à LiveKit");
    }

    await room!.localParticipant?.setMicrophoneEnabled(false);
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

    room!.events.listen((event) {
      if (event is TrackSubscribedEvent) {
        final track = event.track;

        if (track.kind == TrackType.AUDIO) {
          callback(track as RemoteAudioTrack);
        }
      }
    });

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

    room!.events.listen((event) {
      if (event is TrackSubscribedEvent) {
        final track = event.track;

        if (track.kind == TrackType.VIDEO) {
          callback(track as RemoteVideoTrack);
        }
      }
    });

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

    room!.events.listen((event) {
      if (event is ParticipantConnectedEvent) {
        final participant = event.participant;
        debugPrint("Participant connecté : ${participant.identity}");
        callback(true);
      }

      if (event is ParticipantDisconnectedEvent) {
        final participant = event.participant;
        debugPrint("Participant connecté : ${participant.identity}");
        callback(false);
      }
    });

    if (room!.remoteParticipants.isNotEmpty) {
      callback(true);
    }
  }

  static void analyzeAudio(
    RemoteAudioTrack track,
    void Function(double level) callback,
  ) {
    track.addAudioRenderer(
      onFrame: (frame) {
        final samples = frame.data;

        if (samples.isEmpty) {
          callback(0);
          return;
        }

        double sum = 0;

        for (final sample in samples) {
          sum += sample.abs();
        }

        final average = sum / samples.length;

        final level = (average * 100).clamp(0.0, 100.0);

        callback(level);
      },
    );
  }
}
