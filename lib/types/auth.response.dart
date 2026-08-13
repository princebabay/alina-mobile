class Utilisateur {
  final int id;
  final String nomUtilisateur;
  final String email;
  final bool estActif;

  Utilisateur({
    required this.id,
    required this.nomUtilisateur,
    required this.email,
    required this.estActif,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nomUtilisateur: json['nomUtilisateur'],
      email: json['email'],
      estActif: json['estActif'],
    );
  }
}

class LoginResponse {
  final Utilisateur utilisateur;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.utilisateur,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      utilisateur: Utilisateur.fromJson(json['utilisateur']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
