
import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/disease.dart';
import '../models/drug.dart';
import '../models/book.dart';
import '../services/sync_service.dart';

class DataProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  List<Word> _dictionary = [];
  List<Disease> _diseases = [];
  List<Drug> _drugs = [];
  List<Book> _books = [];
  bool _isLoading = false;

  List<Word> get dictionary => _dictionary;
  List<Disease> get diseases => _diseases;
  List<Drug> get drugs => _drugs;
  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dictionary = _syncService.getCachedDictionary().cast<Word>();
      _diseases = _syncService.getCachedDiseases().cast<Disease>();
      _drugs = _syncService.getCachedDrugs().cast<Drug>();
      _books = _syncService.getCachedBooks().cast<Book>();
    } catch (e) {
      print('Error loading cached data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forceSync() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _syncService.forceFullSync();
      await loadData();
    } catch (e) {
      print('Error during force sync: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
