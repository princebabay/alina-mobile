class RegisterRequest {
  final String nomUtilisateur;
  final String email;
  final String motDePasse;
  final String confirmationMotDePasse;

  RegisterRequest({
    required this.nomUtilisateur,
    required this.email,
    required this.motDePasse,
    required this.confirmationMotDePasse,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomUtilisateur': nomUtilisateur,
      'email': email,
      'motDePasse': motDePasse,
      'confirmationMotDePasse': confirmationMotDePasse,
    };
  }
}

class LoginRequest {
  final String email;
  final String motDePasse;

  LoginRequest({required this.email, required this.motDePasse});

  Map<String, dynamic> toJson() {
    return {'email': email, 'motDePasse': motDePasse};
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

class VerifierInscriptionRequest extends RegisterRequest {
  final String code;
  VerifierInscriptionRequest({
    required super.nomUtilisateur,
    required super.email,
    required super.motDePasse,
    required super.confirmationMotDePasse,
    required this.code,
  });
  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'code': code};
}
