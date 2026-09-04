class ParticipantHistoryResponse {
  final int id;
  final int participantId;
  final DateTime dateConnexion;
  final DateTime? dateDeconnexion;

  ParticipantHistoryResponse({
    required this.id,
    required this.participantId,
    required this.dateConnexion,
    this.dateDeconnexion,
  });

  factory ParticipantHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantHistoryResponse(
      id: json['id'],
      participantId: json['participantId'],
      dateConnexion: DateTime.parse(json['dateConnexion']),
      dateDeconnexion: json['dateDeconnexion'] == null
          ? null
          : DateTime.parse(json['dateDeconnexion']),
    );
  }
}

class JoinSessionResponse {
  final Session session;
  final Participant participant;
  final String token;

  JoinSessionResponse({
    required this.session,
    required this.participant,
    required this.token,
  });

  factory JoinSessionResponse.fromJson(Map<String, dynamic> json) {
    return JoinSessionResponse(
      session: Session.fromJson(json['session']),
      participant: Participant.fromJson(json['participant']),
      token: json['token'],
    );
  }
}

class Session {
  final int id;
  final String code;
  final bool estActif;
  final String dateExpiration;
  final String? dateRevocation;
  final int utilisateurId;

  Session({
    required this.id,
    required this.code,
    required this.estActif,
    required this.dateExpiration,
    required this.dateRevocation,
    required this.utilisateurId,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      code: json['code'],
      estActif: json['estActif'],
      dateExpiration: json['dateExpiration'],
      dateRevocation: json['dateRevocation'],
      utilisateurId: json['utilisateurId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'estActif': estActif,
      'dateExpiration': dateExpiration,
      'dateRevocation': dateRevocation,
      'utilisateurId': utilisateurId,
    };
  }
}

class Participant {
  final int id;
  final bool estActif;
  final String dateCreation;
  final int utilisateurId;
  final int roleId;
  final int sessionId;

  Participant({
    required this.id,
    required this.estActif,
    required this.dateCreation,
    required this.utilisateurId,
    required this.roleId,
    required this.sessionId,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      estActif: json['estActif'],
      dateCreation: json['dateCreation'],
      utilisateurId: json['utilisateurId'],
      roleId: json['roleId'],
      sessionId: json['sessionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estActif': estActif,
      'dateCreation': dateCreation,
      'utilisateurId': utilisateurId,
      'roleId': roleId,
      'sessionId': sessionId,
    };
  }
}
