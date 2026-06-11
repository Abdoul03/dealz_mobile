import 'dart:convert';
import 'package:dealz/models/conversation_resume_model.dart';
import 'package:dealz/models/message_model.dart';
import 'package:dealz/services/api_client.dart';

class MessageApiService {
  Future<MessageModel> sendMessage({
    required String destinataireId,
    required String annonceId,
    required String contenu,
  }) async {
    final response = await ApiClient.post('/messages', {
      'destinataireId': destinataireId,
      'annonceId': annonceId,
      'contenu': contenu,
    });
    if (response.statusCode == 201) {
      return MessageModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<List<MessageModel>> getConversation(
      String autreUserId, String annonceId) async {
    final response =
        await ApiClient.get('/messages/conversation/$autreUserId/$annonceId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<List<ConversationResumeModel>> getConversationsResume() async {
    final response = await ApiClient.get('/messages/conversations');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) =>
              ConversationResumeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<void> marquerConversationLue(
      String autreUserId, String annonceId) async {
    await ApiClient.patch(
        '/messages/conversation/$autreUserId/$annonceId/lire');
  }
}
