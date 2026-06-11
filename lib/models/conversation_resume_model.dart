import 'package:dealz/models/user_summary_model.dart';

class ConversationResumeModel {
  final UserSummaryModel interlocuteur;
  final String annonceId;
  final String annonceTitre;
  final String dernierMessage;
  final DateTime dateEnvoi;
  final bool hasUnread;

  ConversationResumeModel({
    required this.interlocuteur,
    required this.annonceId,
    required this.annonceTitre,
    required this.dernierMessage,
    required this.dateEnvoi,
    required this.hasUnread,
  });

  factory ConversationResumeModel.fromJson(Map<String, dynamic> json) {
    return ConversationResumeModel(
      interlocuteur: UserSummaryModel.fromJson(
          json['interlocuteur'] as Map<String, dynamic>),
      annonceId: json['annonceId'] as String,
      annonceTitre: json['annonceTitre'] as String,
      dernierMessage: json['dernierMessage'] as String,
      dateEnvoi: DateTime.parse(json['dateEnvoi'] as String),
      hasUnread: json['hasUnread'] as bool? ?? false,
    );
  }
}
