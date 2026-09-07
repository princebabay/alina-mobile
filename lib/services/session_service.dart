import 'dart:convert';

import 'package:alina_mobile/types/api.response.dart';
import 'package:alina_mobile/types/session.request.dart';
import 'package:alina_mobile/types/session.response.dart';
import 'package:alina_mobile/utils/request_util.dart';
import 'package:alina_mobile/utils/storage_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SessionService {
  static final String apiUrl = dotenv.env['API_URL']!;

  static bool isTerminalClientError(int? statusCode) =>
      statusCode != null && statusCode >= 400 && statusCode < 500;

  static Future<void> synchronizePendingDisconnections() async {
    debugPrint('[SessionService] Synchronisation des déconnexions en attente');
    final participantDisconnect = await StorageUtil.getParticipantDisconnect();

    if (participantDisconnect == null) {
      debugPrint('[SessionService] Aucune déconnexion en attente');
      return;
    }
    debugPrint('[SessionService] Déconnexion en attente trouvée');

    final response = await disconnectParticipant(
      DisconnectParticipantRequest(
        code: participantDisconnect.code,
        date: participantDisconnect.date,
      ),
    );

    if (response.success || isTerminalClientError(response.statusCode)) {
      await StorageUtil.deleteParticipantDisconnect();
    } else {
      debugPrint('[SessionService] Échec synchronisation: ${response.message}');
    }
  }

  static Future<ApiResponse<bool>> checkSessionActivity(
    SessionCodeRequest data,
  ) async {
    try {
      debugPrint('[SessionService] Vérification activité session');
      final response = await http.post(
        Uri.parse('$apiUrl/sessions/check-active'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[SessionService] Activité vérifiée (${response.statusCode})');

      return ApiResponse.fromJson(json, (jsonData) => jsonData as bool);
    } catch (error) {
      debugPrint('[SessionService] Erreur vérification activité: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<bool>> checkSessionExistence(
    SessionCodeRequest data,
  ) async {
    try {
      debugPrint('[SessionService] Vérification existence session');
      final response = await http.post(
        Uri.parse('$apiUrl/sessions/check-existence'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[SessionService] Existence vérifiée (${response.statusCode})');

      return ApiResponse.fromJson(json, (jsonData) => jsonData as bool);
    } catch (error) {
      debugPrint('[SessionService] Erreur vérification existence: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<JoinSessionResponse>> joinSession(
    JoinSessionRequest data,
  ) async {
    try {
      debugPrint('[SessionService] Demande pour rejoindre une session');
      final response = await http.post(
        Uri.parse('$apiUrl/sessions/join'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[SessionService] Réponse join reçue (${response.statusCode})');

      return ApiResponse.fromJson(
        json,
        (jsonData) => JoinSessionResponse.fromJson(jsonData),
      );
    } catch (error) {
      debugPrint('[SessionService] Erreur join session: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<ParticipantHistoryResponse>> connectParticipant(
    SessionCodeRequest data,
  ) async {
    try {
      debugPrint('[SessionService] Connexion du participant');
      final response = await http.post(
        Uri.parse('$apiUrl/sessions/participant/connect'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[SessionService] Participant connecté (${response.statusCode})');

      return ApiResponse.fromJson(
        json,
        (jsonData) => ParticipantHistoryResponse.fromJson(jsonData),
      );
    } catch (error) {
      debugPrint('[SessionService] Erreur connexion participant: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<ParticipantHistoryResponse>> disconnectParticipant(
    DisconnectParticipantRequest data,
  ) async {
    try {
      debugPrint('[SessionService] Déconnexion du participant');
      final response = await http.post(
        Uri.parse('$apiUrl/sessions/participant/disconnect'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[SessionService] Participant déconnecté (${response.statusCode})');

      return ApiResponse.fromJson(
        json,
        (jsonData) => ParticipantHistoryResponse.fromJson(jsonData),
        statusCode: response.statusCode,
      );
    } catch (error) {
      debugPrint('[SessionService] Erreur déconnexion participant: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<Null>> leaveParticipant(
    DisconnectParticipantRequest data,
  ) async {
    try {
      debugPrint('[SessionService] Départ définitif du participant');
      final response = await http.post(
        Uri.parse('$apiUrl/sessions/participant/leave'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[SessionService] Départ traité (${response.statusCode})');

      return ApiResponse.fromJson(json, null);
    } catch (error) {
      debugPrint('[SessionService] Erreur départ participant: $error');
      rethrow;
    }
  }
}
