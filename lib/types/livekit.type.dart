class TokenRequest {
  final String roomName;
  final String role;

  TokenRequest({required this.roomName, required this.role});

  Map<String, dynamic> toJson() {
    return {'roomName': roomName, 'role': role};
  }
}

class TokenResponse {
  final String token;

  TokenResponse({required this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(token: json['token']);
  }
}
