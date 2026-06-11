class UserSummaryModel {
  final String id;
  final String nom;
  final String prenom;
  final double noteMoyenne;

  UserSummaryModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.noteMoyenne,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      noteMoyenne: (json['noteMoyenne'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get nomComplet => '$prenom $nom';
}
