import 'dart:convert';
import 'package:dealz/models/transaction_model.dart';
import 'package:dealz/services/api_client.dart';

class TransactionService {
  Future<TransactionModel> initierTransaction({
    required String annonceId,
    required String typePaiement,
    String? modeRetrait,
  }) async {
    final body = <String, dynamic>{
      'annonceId': annonceId,
      'typePaiement': typePaiement,
    };
    if (modeRetrait != null) body['modeRetrait'] = modeRetrait;

    final response = await ApiClient.post('/transactions', body);
    if (response.statusCode == 201) {
      return TransactionModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<TransactionModel> confirmerTransaction(String id) async {
    final response = await ApiClient.post('/transactions/$id/confirmer');
    if (response.statusCode == 200) {
      return TransactionModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<TransactionModel> annulerTransaction(String id) async {
    final response = await ApiClient.post('/transactions/$id/annuler');
    if (response.statusCode == 200) {
      return TransactionModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<List<TransactionModel>> getMesAchats() async {
    final response = await ApiClient.get('/transactions/achats');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<List<TransactionModel>> getMesVentes() async {
    final response = await ApiClient.get('/transactions/ventes');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }
}
