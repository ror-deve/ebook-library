import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ebook.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<List<Ebook>> fetchEbooks() async {
    final response = await http.get(Uri.parse('$baseUrl/ebooks'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Ebook.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load ebooks.');
    }
  }

  Future<List<Ebook>> searchEbooks(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/ebooks/search?q=$query'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Ebook.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search ebooks.');
    }
  }

  Future<bool> deleteEbook(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/ebooks/$id'));
    return response.statusCode == 204;
  }

  Future<Ebook> uploadEbook(String title, String author, String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ebooks'));
    request.fields['ebook[title]'] = title;
    request.fields['ebook[author]'] = author;
    
    request.files.add(await http.MultipartFile.fromPath('ebook[file]', filePath));
    
    var response = await request.send();
    
    if (response.statusCode == 201) {
      var responseData = await response.stream.bytesToString();
      return Ebook.fromJson(json.decode(responseData));
    } else {
      throw Exception('Failed to upload ebook.');
    }
  }
}
