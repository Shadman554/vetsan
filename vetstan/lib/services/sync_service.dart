import 'dart:async';

import '../database/database_helper.dart';
import '../services/api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiService _apiService = ApiService();
  final DatabaseHelper _database = DatabaseHelper();
  final StreamController<bool> _syncController = StreamController<bool>.broadcast();

  Stream<bool> get syncStream => _syncController.stream;

  Future<void> syncAll() async {
    try {
      _syncController.add(true);
      final dictionary = await _apiService.fetchAllDictionary();
      final diseases = await _apiService.fetchAllDiseases();
      final drugs = await _apiService.fetchAllDrugs();
      final books = await _apiService.fetchAllBooks();

      final db = await _database.database;
      await db.delete('dictionary');
      await db.delete('diseases');
      await db.delete('drugs');
      await db.delete('books');

      for (final word in dictionary) {
        await db.insert('dictionary', {
          'id': word.id,
          'name': word.name,
          'kurdish': word.kurdish,
          'arabic': word.arabic,
          'description': word.description,
          'image_url': word.imageUrl,
        });
      }

      for (final disease in diseases) {
        await db.insert('diseases', {
          'id': disease.id,
          'name': disease.name,
          'cause': disease.cause,
          'control': disease.control,
          'kurdish': disease.kurdish,
          'symptoms': disease.symptoms,
          'category': disease.category,
          'image_url': disease.imageUrl,
        });
      }

      for (final drug in drugs) {
        await db.insert('drugs', {
          'id': drug.id,
          'name': drug.name,
          'description': drug.description,
          'other_info': drug.otherInfo,
          'side_effect': drug.sideEffect,
          'usage': drug.usage,
          'drug_class': drug.drugClass,
          'kurdish': drug.kurdish,
          'category': drug.category,
          'image_url': drug.imageUrl,
        });
      }

      for (final book in books) {
        await db.insert('books', {
          'id': book.id,
          'title': book.title,
          'author': book.author,
          'description': book.description,
          'category': book.category,
          'image_url': book.imageUrl,
        });
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      await _database.updateLastSyncTime('dictionary', now);
      await _database.updateLastSyncTime('diseases', now);
      await _database.updateLastSyncTime('drugs', now);
      await _database.updateLastSyncTime('books', now);

      _syncController.add(false);
    } catch (e) {
      print('Sync failed: $e');
      _syncController.add(false);
      rethrow;
    }
  }
}
