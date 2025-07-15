import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/word.dart';
import '../models/disease.dart';
import '../models/drug.dart';
import '../models/book.dart';
import '../models/normal_range.dart';

class ApiService {
  ApiService();

  static const String _baseUrl =
      'https://python-database-production.up.railway.app';

  Future<List<Book>> fetchAllBooks() async {
    const int limit = 100;
    int skip = 0;
    List<Book> all = [];
    while (true) {
      final page = await _fetchBooksPage(skip: skip, limit: limit);
      if (page.isEmpty) break;
      all.addAll(page);
      if (page.length < limit) break;
      skip += limit;
    }
    return all;
  }

  Future<List<Book>> _fetchBooksPage({int skip = 0, int limit = 100}) async {
    final uri = Uri.parse('$_baseUrl/api/books/?skip=$skip&limit=$limit');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load books – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Word>> fetchAllDictionary() async {
    const int limit = 100;
    int skip = 0;
    List<Word> all = [];
    while (true) {
      final page = await _fetchDictionaryPage(skip: skip, limit: limit);
      if (page.isEmpty) break;
      all.addAll(page);
      if (page.length < limit) break;
      skip += limit;
    }
    return all;
  }

  Future<List<Word>> _fetchDictionaryPage({int skip = 0, int limit = 100}) async {
    final uri = Uri.parse('$_baseUrl/api/dictionary?skip=$skip&limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load dictionary – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Disease>> fetchAllDiseases() async {
    final uri = Uri.parse('$_baseUrl/api/diseases');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load diseases – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Disease.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Drug>> fetchAllDrugs() async {
    final uri = Uri.parse('$_baseUrl/api/drugs');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load drugs – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Drug.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<NormalRange>> fetchAllNormalRanges() async {
    final uri = Uri.parse('$_baseUrl/api/normal_ranges');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load normal ranges – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => NormalRange.fromJson(e as Map<String, dynamic>)).toList();
  }
}
