import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/show.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  Future<List<Show>> fetchShows() async {
    final response = await http.get(Uri.parse('$baseUrl/shows'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((show) => Show.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load shows');
    }
  }

  Future<void> addShow(Show show) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shows'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(show.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add show');
    }
  }

  Future<void> deleteShow(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/shows/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete show');
    }
  }
}