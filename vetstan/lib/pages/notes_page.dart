import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/sync_service.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/history_provider.dart';
import 'note_details_page.dart';
import '../utils/page_transition.dart';


class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  static final SyncService _syncService = SyncService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();



  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;

  void _onNoteTap(BuildContext context, Note note) {
    // Add to history
    Provider.of<HistoryProvider>(context, listen: false).addToHistory(
      note.name,
      'note',
      'Viewed note details'
    );

    // Navigate to note details with custom transition
    Navigator.push(
      context,
      createRoute(NoteDetailsPage(note: note)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _checkForUpdates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final notesList = await _syncService.loadCategoryData<Note>('notes');
      if (mounted) {
        setState(() {
          _notes = notesList.where((note) => note.name.isNotEmpty).toList();
          _filteredNotes = _notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkForUpdates() async {
    // For notes we don’t have an incremental update API yet, so we force a full sync
    await _syncService.forceCategorySync('notes');
    if (!mounted) return;
    final updatedData = await _syncService.loadCategoryData<Note>('notes');
    setState(() {
      _notes = updatedData.where((note) => note.name.isNotEmpty).toList();
      _filterNotes(_searchController.text);
    });
  }

  void _filterNotes(String query) {
    setState(() {
      _filteredNotes = _notes.where((note) {
        final nameMatch = note.name.toLowerCase().contains(query.toLowerCase());
        return nameMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? themeProvider.theme.scaffoldBackgroundColor
          : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 4,
        surfaceTintColor: Colors.transparent,
        backgroundColor: themeProvider.isDarkMode
            ? themeProvider.theme.appBarTheme.backgroundColor
            : themeProvider.theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode
                ? themeProvider.theme.colorScheme.onSurface
                : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Directionality(
          textDirection: languageProvider.textDirection,
          child: Text(
            'تێبینییەکان',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? themeProvider.theme.colorScheme.onSurface
                  : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
            textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Color(0xFF2C2C2C)
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
            ),
            child: Directionality(
              textDirection: languageProvider.textDirection,
              child: TextField(
                controller: _searchController,
                onChanged: _filterNotes,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  hintText: 'گەڕان بە تێبینی...',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                  prefixIcon: languageProvider.isRTL ? null : Icon(
                    Icons.search,
                    color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: languageProvider.isRTL ? Icon(
                    Icons.search,
                    color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ) : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: themeProvider.isDarkMode
                        ? themeProvider.theme.colorScheme.primary
                        : Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading notes...',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _filteredNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 80,
                        color: themeProvider.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'هیچ تێبینییەک نەدۆزرایەوە',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[500],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    physics: const BouncingScrollPhysics(),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      final noteNumber = index + 1; // Calculate note number

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: themeProvider.isDarkMode
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onNoteTap(context, note),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Directionality(
                                textDirection: languageProvider.textDirection,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                  // Section number on the right in RTL
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: themeProvider.isDarkMode
                                          ? Colors.blue.shade300.withOpacity(0.2)
                                          : Colors.blue.shade700.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: themeProvider.isDarkMode
                                            ? Colors.blue.shade300
                                            : Colors.blue.shade700,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        noteNumber.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: themeProvider.isDarkMode
                                              ? Colors.blue.shade300
                                              : Colors.blue.shade700,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Note title right next to the number
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: languageProvider.isRTL ? 8 : 0,
                                        left: languageProvider.isRTL ? 0 : 8,
                                      ),
                                      child: Align(
                                        alignment: languageProvider.isRTL 
                                            ? Alignment.centerRight 
                                            : Alignment.centerLeft,
                                        child: Text(
                                          note.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                            fontFamily: 'Inter',
                                          ),
                                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Image on the left in RTL
                                  if (note.imageUrl != null)
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(note.imageUrl!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}