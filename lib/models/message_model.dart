import 'package:dealz/models/user_summary_model.dart';

class MessageModel {
  final String id;
  final String contenu;
  final DateTime dateEnvoi;
  final bool isRead;
  final UserSummaryModel expediteur;
  final UserSummaryModel destinataire;
  final String annonceId;

  MessageModel({
    required this.id,
    required this.contenu,
    required this.dateEnvoi,
    required this.isRead,
    required this.expediteur,
    required this.destinataire,
    required this.annonceId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      contenu: json['contenu'] as String,
      dateEnvoi: DateTime.parse(json['dateEnvoi'] as String),
      isRead: json['isRead'] as bool? ?? false,
      expediteur: UserSummaryModel.fromJson(
          json['expediteur'] as Map<String, dynamic>),
      destinataire: UserSummaryModel.fromJson(
          json['destinataire'] as Map<String, dynamic>),
      annonceId: json['annonceId'] as String,
    );
  }
}
