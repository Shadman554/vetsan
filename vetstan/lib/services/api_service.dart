import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/word.dart';
import '../models/disease.dart';
import '../models/drug.dart';
import '../models/book.dart';
import '../models/normal_range.dart';
import '../models/note.dart';
import '../models/instrument.dart';
import '../models/slide.dart';

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

  Future<List<Note>> fetchAllNotes() async {
    final uri = Uri.parse('$_baseUrl/api/notes/');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load notes – status \${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Instrument>> fetchAllInstruments() async {
    final uri = Uri.parse('$_baseUrl/api/instruments/');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load instruments – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Instrument.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Slide>> fetchUrineSlides() async {
    final uri = Uri.parse('$_baseUrl/api/urine-slides/');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load urine slides – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Slide.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Slide>> fetchStoolSlides() async {
    final uri = Uri.parse('$_baseUrl/api/stool-slides/');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load stool slides – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Slide.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Slide>> fetchOtherSlides() async {
    final uri = Uri.parse('$_baseUrl/api/other-slides/');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load other slides – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Slide.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Slide> fetchSlideByName(String category, String slideName) async {
    final uri = Uri.parse('$_baseUrl/api/${category.toLowerCase()}-slides/$slideName');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load slide – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    return Slide.fromJson(decoded as Map<String, dynamic>);
  }

  // Incremental sync methods
  Future<List<Word>> fetchDictionaryUpdates({String? since}) async {
    String url = '$_baseUrl/api/dictionary';
    if (since != null) {
      url += '?since=$since';
    }
    
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load dictionary updates – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Disease>> fetchDiseaseUpdates({String? since}) async {
    String url = '$_baseUrl/api/diseases';
    if (since != null) {
      url += '?since=$since';
    }
    
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load disease updates – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Disease.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Drug>> fetchDrugUpdates({String? since}) async {
    String url = '$_baseUrl/api/drugs';
    if (since != null) {
      url += '?since=$since';
    }
    
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load drug updates – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Drug.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Book>> fetchBookUpdates({String? since}) async {
    String url = '$_baseUrl/api/books/';
    if (since != null) {
      url += '?since=$since';
    }
    
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load book updates – status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    final List<dynamic> jsonData = decoded is List ? decoded : (decoded['items'] as List<dynamic>);
    return jsonData.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> checkForUpdates() async {
    final uri = Uri.parse('$_baseUrl/api/updates/check');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to check for updates – status ${response.statusCode}');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }
}
