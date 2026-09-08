import 'dart:convert';

import 'package:alina_mobile/types/api.response.dart';
import 'package:alina_mobile/types/session.request.dart';
import 'package:alina_mobile/types/session.response.dart';
import 'package:alina_mobile/utils/request_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SessionService {
  static final String apiUrl = dotenv.env['API_URL']!;

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
      debugPrint(
        '[SessionService] Réponse join reçue (${response.statusCode})',
      );

      return ApiResponse.fromJson(
        json,
        (jsonData) => JoinSessionResponse.fromJson(jsonData),
      );
    } catch (error) {
      debugPrint('[SessionService] Erreur join session: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<ActiveParticipantSessionResponse>>
  getActiveParticipantSession() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/sessions/participant/active'),
        headers: await RequestUtil.authHeaders(),
      );

      final json = jsonDecode(response.body);

      return ApiResponse.fromJson(
        json,
        (jsonData) => ActiveParticipantSessionResponse.fromJson(jsonData),
      );
    } catch (error) {
      debugPrint(
        '[SessionService] Erreur recuperation participant actif: $error',
      );
      rethrow;
    }
  }

  static Future<ApiResponse<Null>> leaveParticipant(
    SessionEndRequest data,
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
