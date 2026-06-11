class CategorieModel {
  final String id;
  final String nom;

  CategorieModel({required this.id, required this.nom});

  factory CategorieModel.fromJson(Map<String, dynamic> json) {
    return CategorieModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
    );
  }
}
