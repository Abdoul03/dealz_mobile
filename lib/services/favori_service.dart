import 'dart:convert';

import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/services/api_client.dart';

class FavoriService {
  Future<List<AnnonceModel>> getMesFavoris() async {
    final response = await ApiClient.get('/favoris');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => AnnonceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<Set<String>> getMesFavorisIds() async {
    final response = await ApiClient.get('/favoris/ids');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).cast<String>().toSet();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<void> ajouter(String annonceId) async {
    final response = await ApiClient.post('/favoris/$annonceId');
    if (response.statusCode != 204) {
      throw Exception(ApiClient.parseError(response));
    }
  }

  Future<void> retirer(String annonceId) async {
    final response = await ApiClient.delete('/favoris/$annonceId');
    if (response.statusCode != 204) {
      throw Exception(ApiClient.parseError(response));
    }
  }
}
