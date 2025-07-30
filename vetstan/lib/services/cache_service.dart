import 'package:hive_flutter/hive_flutter.dart';
import '../models/word.dart';
import '../models/disease.dart';
import '../models/drug.dart';
import '../models/note.dart';
import '../models/book.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _dictionaryBox = 'dictionary';
  static const String _diseasesBox = 'diseases';
  static const String _drugsBox = 'drugs';
  static const String _booksBox = 'books';
  static const String _notesBox = 'notes';
  static const String _metadataBox = 'metadata';

  late Box<Map> _dictionaryCache;
  late Box<Map> _diseasesCache;
  late Box<Map> _drugsCache;
  late Box<Map> _booksCache;
  late Box<Map> _notesCache;
  late Box<String> _metadataCache;

  Future<void> init() async {
    await Hive.initFlutter();

    _dictionaryCache = await Hive.openBox<Map>(_dictionaryBox);
    _diseasesCache = await Hive.openBox<Map>(_diseasesBox);
    _drugsCache = await Hive.openBox<Map>(_drugsBox);
    _booksCache = await Hive.openBox<Map>(_booksBox);
    _notesCache = await Hive.openBox<Map>(_notesBox);
    _metadataCache = await Hive.openBox<String>(_metadataBox);
  }

  // Dictionary methods
  Future<void> cacheDictionary(List<Word> words) async {
    final Map<String, Map<String, dynamic>> wordMap = {};
    for (final word in words) {
      wordMap[word.id] = word.toJson();
    }
    await _dictionaryCache.putAll(wordMap);
    await _setDataLoaded('dictionary', true);
  }

  Future<void> mergeDictionaryUpdates(List<Word> updates) async {
    for (final word in updates) {
      await _dictionaryCache.put(word.id, word.toJson());
    }
  }

  List<Word> getCachedDictionary() {
    return _dictionaryCache.values
        .map((json) => Word.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  // Disease methods
  Future<void> cacheDiseases(List<Disease> diseases) async {
    final Map<String, Map<String, dynamic>> diseaseMap = {};
    for (final disease in diseases) {
      diseaseMap[disease.id] = disease.toJson();
    }
    await _diseasesCache.putAll(diseaseMap);
    await _setDataLoaded('diseases', true);
  }

  Future<void> mergeDiseaseUpdates(List<Disease> updates) async {
    for (final disease in updates) {
      await _diseasesCache.put(disease.id, disease.toJson());
    }
  }

  List<Disease> getCachedDiseases() {
    return _diseasesCache.values
        .map((json) => Disease.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  // Drug methods
  Future<void> cacheDrugs(List<Drug> drugs) async {
    final Map<String, Map<String, dynamic>> drugMap = {};
    for (final drug in drugs) {
      drugMap[drug.id] = drug.toJson();
    }
    await _drugsCache.putAll(drugMap);
    await _setDataLoaded('drugs', true);
  }

  Future<void> mergeDrugUpdates(List<Drug> updates) async {
    for (final drug in updates) {
      await _drugsCache.put(drug.id, drug.toJson());
    }
  }

  List<Drug> getCachedDrugs() {
    return _drugsCache.values
        .map((json) => Drug.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  // Note methods
  Future<void> cacheNotes(List<Note> notes) async {
    final Map<String, Map<String, dynamic>> noteMap = {};
    for (final note in notes) {
      noteMap[note.name] = note.toJson();
    }
    await _notesCache.putAll(noteMap);
    await _setDataLoaded('notes', true);
  }

  Future<void> mergeNoteUpdates(List<Note> updates) async {
    for (final note in updates) {
      await _notesCache.put(note.name, note.toJson());
    }
  }

  List<Note> getCachedNotes() {
    return _notesCache.values
        .map((json) => Note.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  // Book methods
  Future<void> cacheBooks(List<Book> books) async {
    final Map<String, Map<String, dynamic>> bookMap = {};
    for (final book in books) {
      bookMap[book.id] = book.toJson();
    }
    await _booksCache.putAll(bookMap);
    await _setDataLoaded('books', true);
  }

  Future<void> mergeBookUpdates(List<Book> updates) async {
    for (final book in updates) {
      await _booksCache.put(book.id, book.toJson());
    }
  }

  List<Book> getCachedBooks() {
    return _booksCache.values
        .map((json) => Book.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  // Data loading state methods
  Future<void> _setDataLoaded(String dataType, bool loaded) async {
    await _metadataCache.put('${dataType}_loaded', loaded.toString());
  }

  bool isDataLoaded(String dataType) {
    return _metadataCache.get('${dataType}_loaded') == 'true';
  }

  bool hasCachedData(String dataType) {
    switch (dataType) {
      case 'dictionary':
        return _dictionaryCache.isNotEmpty;
      case 'diseases':
        return _diseasesCache.isNotEmpty;
      case 'drugs':
        return _drugsCache.isNotEmpty;
      case 'books':
        return _booksCache.isNotEmpty;
      case 'notes':
        return _notesCache.isNotEmpty;
      default:
        return false;
    }
  }

  // Metadata methods
  Future<void> setLastSyncTime(String dataType, String timestamp) async {
    await _metadataCache.put('last_sync_$dataType', timestamp);
  }

  String? getLastSyncTime(String dataType) {
    return _metadataCache.get('last_sync_$dataType');
  }

  Future<void> setFirstInstall(bool isFirst) async {
    await _metadataCache.put('first_install', isFirst.toString());
  }

  bool isFirstInstall() {
    return _metadataCache.get('first_install') == 'true' || 
           _metadataCache.get('first_install') == null;
  }

  // Clear methods
  Future<void> clearAllCache() async {
    await _dictionaryCache.clear();
    await _diseasesCache.clear();
    await _drugsCache.clear();
    await _booksCache.clear();
    await _notesCache.clear();
    await _metadataCache.clear();
  }

  Future<void> clearCategoryCache(String dataType) async {
    switch (dataType) {
      case 'dictionary':
        await _dictionaryCache.clear();
        break;
      case 'diseases':
        await _diseasesCache.clear();
        break;
      case 'drugs':
        await _drugsCache.clear();
        break;
      case 'books':
        await _booksCache.clear();
        break;
      case 'notes':
        await _notesCache.clear();
        break;
    }
    await _setDataLoaded(dataType, false);
  }

  bool hasData() {
    return _dictionaryCache.isNotEmpty || 
           _diseasesCache.isNotEmpty || 
           _drugsCache.isNotEmpty || 
           _booksCache.isNotEmpty;
  }
}