import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../types/auth.request.dart';
import '../types/auth.response.dart';
import '../types/api.response.dart';

class AuthService {
  static final String apiUrl = dotenv.env['API_URL']!;

  static Future<ApiResponse<Utilisateur>> register(RegisterRequest data) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);

      return ApiResponse.fromJson(
        json,
        (jsonData) => Utilisateur.fromJson(jsonData),
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<ApiResponse<LoginResponse>> login(LoginRequest data) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      final json = jsonDecode(response.body);

      return ApiResponse.fromJson(
        json,
        (jsonData) => LoginResponse.fromJson(jsonData),
      );
    } catch (error) {
      rethrow;
    }
  }
}
