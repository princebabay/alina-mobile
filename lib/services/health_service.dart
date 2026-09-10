import 'dart:convert';

import 'package:alina_mobile/types/api.response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HealthService {
  static final String apiUrl = dotenv.env['API_URL']!;

  static Future<ApiResponse<bool>> checkBackendHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/health'))
          .timeout(const Duration(seconds: 3));
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
        (jsonData) => jsonData['status'] == 'ok',
        statusCode: response.statusCode,
      );
    } catch (error) {
      debugPrint('[HealthService] Backend indisponible: $error');
      rethrow;
    }
  }
}
