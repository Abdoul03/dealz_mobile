import 'package:dealz/models/user_summary_model.dart';

class TransactionModel {
  final String id;
  final double montant;
  final String statut;
  final DateTime? dateTransaction;
  final String? modeRetrait;
  final String annonceId;
  final String annonceTitre;
  final UserSummaryModel acheteur;
  final UserSummaryModel vendeur;
  final bool acheteurConfirmeRemise;
  final bool vendeurConfirmeRemise;

  TransactionModel({
    required this.id,
    required this.montant,
    required this.statut,
    this.dateTransaction,
    this.modeRetrait,
    required this.annonceId,
    required this.annonceTitre,
    required this.acheteur,
    required this.vendeur,
    required this.acheteurConfirmeRemise,
    required this.vendeurConfirmeRemise,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      montant: (json['montant'] as num).toDouble(),
      statut: json['statut'] as String,
      dateTransaction: json['dateTransaction'] != null
          ? DateTime.tryParse(json['dateTransaction'] as String)
          : null,
      modeRetrait: json['modeRetrait'] as String?,
      annonceId: json['annonceId'] as String,
      annonceTitre: json['annonceTitre'] as String,
      acheteur: UserSummaryModel.fromJson(
          json['acheteur'] as Map<String, dynamic>),
      vendeur: UserSummaryModel.fromJson(
          json['vendeur'] as Map<String, dynamic>),
      acheteurConfirmeRemise: json['acheteurConfirmeRemise'] as bool? ?? false,
      vendeurConfirmeRemise: json['vendeurConfirmeRemise'] as bool? ?? false,
    );
  }

  String get statutLabel {
    switch (statut) {
      case 'EN_COURS':
        return 'En cours';
      case 'CONFIRMATION_PARTIELLE':
        return 'Remise à confirmer';
      case 'SEQUESTRE':
        return 'Ancienne transaction';
      case 'CONFIRMEE':
        return 'Confirmée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return statut;
    }
  }
}
