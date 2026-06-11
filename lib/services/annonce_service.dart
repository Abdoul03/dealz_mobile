import 'dart:convert';
import 'package:dealz/models/annonce_model.dart';
import 'package:dealz/models/categorie_model.dart';
import 'package:dealz/services/api_client.dart';

class AnnonceService {
  Future<List<AnnonceModel>> getAnnonces({
    String? categorieId,
    String? motCle,
  }) async {
    String path = '/annonces';
    final params = <String, String>{};
    if (categorieId != null && categorieId.isNotEmpty) {
      params['categorieId'] = categorieId;
    }
    if (motCle != null && motCle.isNotEmpty) {
      params['motCle'] = motCle;
    }
    if (params.isNotEmpty) {
      path += '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    }
    final response = await ApiClient.get(path);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => AnnonceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<AnnonceModel> getAnnonceById(String id) async {
    final response = await ApiClient.get('/annonces/$id');
    if (response.statusCode == 200) {
      return AnnonceModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<List<AnnonceModel>> getMesAnnonces() async {
    final response = await ApiClient.get('/annonces/mes-annonces');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => AnnonceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<List<AnnonceModel>> getAnnoncesByVendeur(String vendeurId) async {
    final response = await ApiClient.get('/annonces/vendeur/$vendeurId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => AnnonceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<AnnonceModel> publierAnnonce(String id) async {
    final response = await ApiClient.post('/annonces/$id/publier');
    if (response.statusCode == 200) {
      return AnnonceModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(ApiClient.parseError(response));
  }

  Future<List<CategorieModel>> getCategories() async {
    try {
      final response = await ApiClient.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => CategorieModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
