import 'package:alina_mobile/utils/storage_util.dart';

class RequestUtil {
  static Future<Map<String, String>> authHeaders() async {
    String? accessToken = await StorageUtil.getAccessToken();

    if (accessToken != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
    }

    return {'Content-Type': 'application/json'};
  }
}
