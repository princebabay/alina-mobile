class SessionCodeRequest {
  final String code;

  SessionCodeRequest({required this.code});

  Map<String, dynamic> toJson() {
    return {'code': code};
  }
}

class JoinSessionRequest extends SessionCodeRequest {
  final String role;

  JoinSessionRequest({required super.code, required this.role});

  @override
  Map<String, dynamic> toJson() {
    return {'code': code, 'role': role};
  }
}

class SessionEndRequest extends SessionCodeRequest {
  final DateTime? date;

  SessionEndRequest({required super.code, this.date});

  @override
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      if (date != null) 'date': date!.toUtc().toIso8601String(),
    };
  }
}

class SessionDateRequest extends SessionCodeRequest {
  final DateTime date;

  SessionDateRequest({required super.code, required this.date});

  @override
  Map<String, dynamic> toJson() {
    return {'code': code, 'date': date.toUtc().toIso8601String()};
  }

  factory SessionDateRequest.fromJson(Map<String, dynamic> json) {
    return SessionDateRequest(
      code: json['code'] as String,
      date: DateTime.parse(json['date'] as String).toUtc(),
    );
  }
}
