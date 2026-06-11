import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dealz/_base/constant.dart';
import 'package:dealz/services/auth_service.dart';

class MediaService {
  Future<String> uploadImage(File imageFile) async {
    final token = await AuthService().getAccessToken();
    final uri = Uri.parse('${Constant.remoteUrl}/media/upload');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${token ?? ''}'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['url'] as String;
    }
    final err = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(err['message'] ?? 'Erreur lors du téléchargement de l\'image.');
  }

  Future<List<String>> uploadImages(List<File> files) async {
    final urls = <String>[];
    for (final file in files) {
      urls.add(await uploadImage(file));
    }
    return urls;
  }
}
