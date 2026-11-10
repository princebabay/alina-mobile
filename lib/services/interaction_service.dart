import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../types/api.response.dart';
import '../types/interaction.dart';
import '../utils/request_util.dart';

class InteractionService {
  static String get _api => dotenv.env['API_URL']!;

  static Future<ApiResponse<List<SessionMessage>>> getMessages(
    String code, {
    int? before,
    int? after,
  }) async {
    final path = after == null ? 'messages' : 'messages/newer';
    final uri = Uri.parse('$_api/sessions/${Uri.encodeComponent(code)}/$path')
        .replace(
          queryParameters: before != null
              ? {'id': '$before'}
              : after != null
              ? {'afterId': '$after'}
              : null,
        );
    final response = await http.get(
      uri,
      headers: await RequestUtil.authHeaders(),
    );
    return ApiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((e) => SessionMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> sendMessage(
    String code,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse('$_api/sessions/${Uri.encodeComponent(code)}/messages'),
      headers: await RequestUtil.authHeaders(),
      body: jsonEncode({'contenu': content}),
    );
    return ApiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<List<Poll>>> getPolls(
    String code, {
    bool history = false,
  }) async {
    final route = history ? 'history' : 'active';
    final response = await http.get(
      Uri.parse('$_api/sessions/${Uri.encodeComponent(code)}/sondages/$route'),
      headers: await RequestUtil.authHeaders(),
    );
    return ApiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((e) => Poll.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<Null>> vote(int pollId, int optionId) async {
    final response = await http.post(
      Uri.parse('$_api/sondages/$pollId/votes'),
      headers: await RequestUtil.authHeaders(),
      body: jsonEncode({'optionId': optionId}),
    );
    return ApiResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
      null,
      statusCode: response.statusCode,
    );
  }
}
