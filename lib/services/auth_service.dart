import 'dart:convert';
import 'package:alina_mobile/utils/request_util.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../types/auth.request.dart';
import '../types/auth.response.dart';
import '../types/api.response.dart';

class AuthService {
  static final String apiUrl = dotenv.env['API_URL']!;

  static Future<ApiResponse<LoginResponse>> register(
    RegisterRequest data,
  ) async {
    try {
      debugPrint('[AuthService] Inscription en cours');
      final response = await http.post(
        Uri.parse('$apiUrl/auth/register'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[AuthService] Inscription terminée (${response.statusCode})');

      return ApiResponse.fromJson(
        json,
        (jsonData) => LoginResponse.fromJson(jsonData),
      );
    } catch (error) {
      debugPrint('[AuthService] Erreur inscription: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<LoginResponse>> login(LoginRequest data) async {
    try {
      debugPrint('[AuthService] Connexion en cours');
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[AuthService] Connexion terminée (${response.statusCode})');

      return ApiResponse.fromJson(
        json,
        (jsonData) => LoginResponse.fromJson(jsonData),
      );
    } catch (error) {
      debugPrint('[AuthService] Erreur connexion: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<LoginResponse>> refreshTokenAPI(
    RefreshTokenRequest data,
  ) async {
    try {
      debugPrint('[AuthService] Rafraîchissement du token');
      final response = await http.post(
        Uri.parse('$apiUrl/auth/refresh-token'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[AuthService] Token rafraîchi (${response.statusCode})');

      return ApiResponse.fromJson(
        json,
        (jsonData) => LoginResponse.fromJson(jsonData),
      );
    } catch (error) {
      debugPrint('[AuthService] Erreur refresh token: $error');
      rethrow;
    }
  }

  static Future<ApiResponse<Null>> revokeTokenAPI(
    RefreshTokenRequest data,
  ) async {
    try {
      debugPrint('[AuthService] Révocation du token');
      final response = await http.post(
        Uri.parse('$apiUrl/auth/revoke-token'),
        headers: await RequestUtil.authHeaders(),
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);
      debugPrint('[AuthService] Token révoqué (${response.statusCode})');

      return ApiResponse.fromJson(json, null);
    } catch (error) {
      debugPrint('[AuthService] Erreur révocation token: $error');
      rethrow;
    }
  }
}
