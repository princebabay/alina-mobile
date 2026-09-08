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
