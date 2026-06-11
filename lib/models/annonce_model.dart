import 'package:dealz/models/categorie_model.dart';
import 'package:dealz/models/user_summary_model.dart';

class AnnonceModel {
  final String id;
  final String titre;
  final String description;
  final double prix;
  final String? urlImage;
  final List<String> urlImages;
  final String etat;
  final String statut;
  final DateTime? datePublication;
  final bool isBoosted;
  final String? pointRetrait;
  final UserSummaryModel vendeur;
  final CategorieModel categorie;

  AnnonceModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    this.urlImage,
    required this.urlImages,
    required this.etat,
    required this.statut,
    this.datePublication,
    required this.isBoosted,
    this.pointRetrait,
    required this.vendeur,
    required this.categorie,
  });

  factory AnnonceModel.fromJson(Map<String, dynamic> json) {
    return AnnonceModel(
      id: json['id'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      prix: (json['prix'] as num).toDouble(),
      urlImage: json['urlImage'] as String?,
      urlImages: (json['urlImages'] as List<dynamic>?)?.cast<String>() ?? [],
      etat: json['etat'] as String,
      statut: json['statut'] as String,
      datePublication: json['datePublication'] != null
          ? DateTime.tryParse(json['datePublication'] as String)
          : null,
      isBoosted: json['isBoosted'] as bool? ?? false,
      pointRetrait: json['pointRetrait'] as String?,
      vendeur: UserSummaryModel.fromJson(
          json['vendeur'] as Map<String, dynamic>),
      categorie: CategorieModel.fromJson(
          json['categorie'] as Map<String, dynamic>),
    );
  }

  String get etatLabel {
    switch (etat) {
      case 'NEUF':
        return 'Neuf';
      case 'TRES_BON_ETAT':
        return 'Très bon état';
      case 'BON_ETAT':
        return 'Bon état';
      case 'USAGE':
        return 'Usagé';
      default:
        return etat;
    }
  }
}
