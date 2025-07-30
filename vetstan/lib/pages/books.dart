import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _books = [];
  final List<Map<String, dynamic>> _recentBooks = [];
  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _filteredBooks = [];
  String _selectedCategory = 'هەموو کتێبەکان';

  String _getDatabaseCategory(String displayCategory) {
    // Map Kurdish UI text to English database categories
    switch (displayCategory) {
      case 'هەموو کتێبەکان':
        return 'All';
      case 'کتێبە کوردیەکان':
        return 'Kurdish';
      case 'کتێبە عەرەبیەکان':
        return 'Arabic';
      case 'کتێبە ئینگلیزیەکان':
        return 'English';
      default:
        return displayCategory;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBooks();
    _loadRecentBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _loadRecentBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final recentBooks = prefs.getStringList('recentBooks') ?? [];
    setState(() {
      _recentBooks.clear();
      _recentBooks.addAll(
        recentBooks.map((book) => Map<String, dynamic>.from(jsonDecode(book))),
      );
    });
  }

  Future<void> _addToRecentBooks(Map<String, dynamic> book) async {
    final prefs = await SharedPreferences.getInstance();
    final recentBooks = prefs.getStringList('recentBooks') ?? [];

    recentBooks.removeWhere((b) {
      final Map<String, dynamic> bookMap = jsonDecode(b);
      return bookMap['id'] == book['id'];
    });

    recentBooks.insert(0, jsonEncode(book));

    if (recentBooks.length > 10) {
      recentBooks.removeLast();
    }

    await prefs.setStringList('recentBooks', recentBooks);
    await _loadRecentBooks();
  }

  void _filterBooks(String query) {
    final dbCategory = _getDatabaseCategory(_selectedCategory);

    setState(() {
      if (query.isEmpty) {
        _filteredBooks = dbCategory == 'All'
            ? List.from(_books)
            : _books.where((book) => book['category'] == dbCategory).toList();
        _removeOverlay();
      } else {
        _filteredBooks = _books.where((book) {
          final title = book['title'].toString().toLowerCase();
          final author = book['author'].toString().toLowerCase();
          final description = book['description'].toString().toLowerCase();
          final searchLower = query.toLowerCase();

          final matchesSearch = title.contains(searchLower) ||
              author.contains(searchLower) ||
              description.contains(searchLower);

          return dbCategory == 'All'
              ? matchesSearch
              : matchesSearch && book['category'] == dbCategory;
        }).toList();
        _showSearchResults();
      }
    });
  }

  void _showSearchResults() {
    _removeOverlay();

    if (_searchController.text.isEmpty || _filteredBooks.isEmpty) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 48.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(book['title'] ?? ''),
                    subtitle: Text(book['author'] ?? ''),
                    onTap: () {
                      _removeOverlay();
                      _searchController.clear();
                      _addToRecentBooks(book);
                      _openPDF(book['downloadUrl'], book['title']);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode
                      ? theme.colorScheme.onSurface.withOpacity(0.12)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.search,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: Provider.of<LanguageProvider>(context).textDirection,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterBooks,
                        textDirection: Provider.of<LanguageProvider>(context).textDirection,
                        decoration: InputDecoration(
                          hintText: 'گەڕان بۆ کتێب...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.6)
                                : Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _filterBooks('');
                      },
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCategoryChip('هەموو کتێبەکان'),
                _buildCategoryChip('کتێبە کوردیەکان'),
                _buildCategoryChip('کتێبە عەرەبیەکان'),
                _buildCategoryChip('کتێبە ئینگلیزیەکان'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Directionality(
          textDirection: languageProvider.textDirection,
          child: Text(
            category,
            style: const TextStyle(
              fontFamily: 'Inter',
            ),
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
            _filterBooks(_searchController.text);
          });
        },
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildBookGrid(List<Map<String, dynamic>> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => _buildBookGridItem(books[index]),
    );
  }

  Widget _buildBookGridItem(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        _addToRecentBooks(book);
        _openPDF(book['downloadUrl'], book['title']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: book['coverUrl'] != null && book['coverUrl'].isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book['coverUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => _buildShimmerEffect(),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).disabledColor,
                          child: const Icon(Icons.book, size: 40),
                        ),
                      )
                    : Container(
                        color: Theme.of(context).disabledColor,
                        child: const Icon(Icons.book, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: Provider.of<LanguageProvider>(context).textDirection,
                    child: Text(
                      book['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: Provider.of<LanguageProvider>(context).isRTL 
                          ? TextAlign.right 
                          : TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: Provider.of<LanguageProvider>(context).textDirection,
                    child: Text(
                      book['author'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: Provider.of<LanguageProvider>(context).isRTL 
                          ? TextAlign.right 
                          : TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Directionality(
          textDirection: languageProvider.textDirection,
          child: const Text(
            'کتێبەکان',
            style: TextStyle(fontFamily: 'Inter'),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Directionality(
                textDirection: languageProvider.textDirection,
                child: const Text(
                  'هەموو کتێبەکان',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
            ),
            Tab(
              child: Directionality(
                textDirection: languageProvider.textDirection,
                child: const Text(
                  'خوێندراوەکان',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Directionality(
                        textDirection: languageProvider.textDirection,
                        child: const Text(
                          'ببورە کێشەیەک ڕوویدا!',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadBooks,
                        child: Directionality(
                          textDirection: languageProvider.textDirection,
                          child: const Text(
                            'دووبارەی بکەوە',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        _buildSearchBar(),
                        Expanded(
                          child: _filteredBooks.isEmpty && _searchController.text.isNotEmpty
                              ? Center(
                                  child: Directionality(
                                    textDirection: languageProvider.textDirection,
                                    child: const Text(
                                      'هیچ کتێبێک نەدۆزرایەوە',
                                      style: TextStyle(fontFamily: 'Inter'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : _buildBookGrid(_filteredBooks.isEmpty
                                  ? _books
                                  : _filteredBooks),
                        ),
                      ],
                    ),
                    _recentBooks.isEmpty
                        ? Center(
                            child: Directionality(
                              textDirection: languageProvider.textDirection,
                              child: const Text(
                                'هیچ کتێبێکت نەخوێندوەتەوە',
                                style: TextStyle(fontFamily: 'Inter'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _buildBookGrid(_recentBooks),
                  ],
                ),
    );
  }

  Future<void> _loadBooks() async {
    try {
      await _loadCachedBooks();

      final apiService = ApiService();
      final books = await apiService.fetchAllBooks();

      final List<Map<String, dynamic>> bookMaps = books.map((book) => {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'downloadUrl': book.downloadUrl,
        'description': book.description,
        'coverUrl': book.imageUrl,
        'category': book.category,
      }).toList();

      if (mounted) {
        setState(() {
          _books.clear();
          _books.addAll(bookMaps);
          _isLoading = false;
        });
      }

      await _cacheBooks(bookMaps);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCachedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedBooks = prefs.getStringList('books');
      if (cachedBooks != null && mounted) {
        setState(() {
          _books.clear();
          _books.addAll(cachedBooks
              .map((book) => Map<String, dynamic>.from(jsonDecode(book)))
              .toList());
        });
      }
    } catch (e) {
      // Handle cache loading error
      // print('Error loading cached books: $e');
    }
  }

  Future<void> _cacheBooks(List<Map<String, dynamic>> books) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'books', books.map((book) => jsonEncode(book)).toList());
    } catch (e) {
      // Handle cache saving error
      // print('Error caching books: $e');
    }
  }

  void _openPDF(String url, String title) {
    String pdfUrl = url;
    if (url.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (match != null) {
        final fileId = match.group(1);
        pdfUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(
          url: pdfUrl,
          title: title,
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).disabledColor,
      highlightColor: Theme.of(context).highlightColor,
      child: Container(
        width: 100,
        height: 140,
        color: Theme.of(context).cardColor,
      ),
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool _isDarkMode = false;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isSearching = false;
  double _loadingProgress = 0;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final ValueNotifier<bool> _isToolbarVisible = ValueNotifier<bool>(true);
  CancelToken? _cancelToken;
  Uint8List? _cachedPdfData;
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  int _currentSearchIndex = 0;
  bool _isDisposed = false;
  bool _isPdfLoadedFromFile = false; // New state to track if PDF is loaded from file cache

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _pdfViewerController.dispose();
    _isToolbarVisible.dispose();
    _searchResult.clear();
    _cancelToken?.cancel(); // Cancel any ongoing download
    _cachedPdfData = null; // Clear cached data
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadPdf() async {
    if (_isDisposed) return;

    _safeSetState(() {
      _isLoading = true;
      _loadingProgress = 0;
      _cachedPdfData = null; // Reset cached data
      _isPdfLoadedFromFile = false; // Reset file loaded status
    });

    _cancelToken = CancelToken();
    try {
      final cacheDir = await getTemporaryDirectory();
      final cachedPdfFile = File('${cacheDir.path}/${widget.url.hashCode}.pdf');

      // Check if PDF is cached and valid
      if (await cachedPdfFile.exists()) {
        try {
          final fileSize = await cachedPdfFile.length();
          const maxMemoryLoadSize = 100 * 1024 * 1024; // 100 MB

          if (fileSize > maxMemoryLoadSize) {
            // For very large files, avoid loading into memory. Rely on network streaming from local file.
            if (!_isDisposed && mounted) {
              _safeSetState(() {
                _isLoading = false;
                _isPdfLoadedFromFile = true; // Indicate it's from local cache (streaming)
                _loadingProgress = 100;
              });
              _showSnackBar('Large PDF found in cache. Streaming from local storage.');
              return;
            }
          } else {
            // For smaller files, load into memory
            final allBytes = await cachedPdfFile.readAsBytes();
            if (!_isDisposed && mounted) {
              _safeSetState(() {
                _cachedPdfData = allBytes;
                _isLoading = false;
                _isPdfLoadedFromFile = true; // Indicate it's from local cache (in-memory)
                _loadingProgress = 100;
              });
              _showSnackBar('PDF loaded from cache.');
              return;
            }
          }
        } catch (e) {
          // If cached file is corrupted or causes error, delete it and re-download
          // print('Error reading cached PDF: $e. Deleting and re-downloading.');
          if (!_isDisposed) {
            await cachedPdfFile.delete();
          }
        }
      }

      // If not cached or cache is invalid, download from network
      _showSnackBar('کتێبەکە دادەبەزێت...');
      final dio = Dio();
      final response = await dio.get(
        widget.url,
        options: Options(responseType: ResponseType.bytes, receiveTimeout: const Duration(seconds: 60)), // Increased timeout
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1 && !_isDisposed && mounted) {
            _safeSetState(() {
              _loadingProgress = (received / total * 100).toDouble();
            });
          }
        },
      );

      // Save the downloaded bytes to cache
      await cachedPdfFile.writeAsBytes(response.data as List<int>);

      // Determine whether to load into memory or stream from local file
      const maxMemoryLoadSize = 100 * 1024 * 1024; // 100 MB
      if ((response.data as List<int>).length > maxMemoryLoadSize) {
        if (!_isDisposed && mounted) {
          _safeSetState(() {
            _isLoading = false;
            _isPdfLoadedFromFile = true; // Use network viewer but from local file
            _loadingProgress = 100;
          });
          _showSnackBar('Large PDF downloaded. Streaming from local storage.');
        }
      } else {
        if (!_isDisposed && mounted) {
          _safeSetState(() {
            _cachedPdfData = Uint8List.fromList(response.data as List<int>);
            _isLoading = false;
            _isPdfLoadedFromFile = true; // Loaded into memory from local file
            _loadingProgress = 100;
          });
          _showSnackBar('PDF downloaded and loaded.');
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // print('PDF download cancelled.');
      } else {
        if (!_isDisposed && mounted) {
          _safeSetState(() {
            _isLoading = false;
            _loadingProgress = 0;
          });
          String errorMessage = 'Error loading PDF. Please check your internet connection and try again.';
          if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'PDF download timed out. Please try again.';
          } else if (e.response != null) {
            errorMessage = 'Error: ${e.response?.statusCode} - Failed to download PDF.';
          }
          _showSnackBar(errorMessage);
        }
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        _safeSetState(() {
          _isLoading = false;
          _loadingProgress = 0;
        });
        _showSnackBar('An unexpected error occurred: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    // SnackBar disabled as per request
  }

  void _handleSearch(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _searchResult = PdfTextSearchResult();
        _currentSearchIndex = 0;
      });
      return;
    }

    _searchResult = _pdfViewerController.searchText(
      searchText,
    );

    _searchResult.addListener(() {
      if (mounted) {
        _safeSetState(() {
          if (_searchResult.hasResult) {
            _currentSearchIndex = _searchResult.currentInstanceIndex;
          } else {
            _currentSearchIndex = 0;
          }
        });
      }
    });
  }

  void _jumpToNextSearchResult() {
    if (_searchResult.hasResult) {
      _searchResult.nextInstance();
    }
  }

  void _jumpToPreviousSearchResult() {
    if (_searchResult.hasResult) {
      _searchResult.previousInstance();
    }
  }

  Future<void> _jumpToPage(int page) async {
    _pdfViewerController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _isDarkMode;

    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : Theme.of(context).cardColor;
    final surfaceColor = isDark ? const Color(0xFF2D2D2D) : Theme.of(context).cardColor;
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;
    final onSurfaceColorMuted = isDark ? Colors.white70 : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: surfaceColor,
          foregroundColor: onSurfaceColor,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: _isToolbarVisible.value
            ? AppBar(
                title: Text(
                  widget.title,
                  style: TextStyle(
                    color: onSurfaceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: onSurfaceColor),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: onSurfaceColor,
                    ),
                    onPressed: () {
                      _safeSetState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          _pdfViewerController.clearSelection();
                          _searchResult.clear(); // Clear search results when closing search
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: onSurfaceColor,
                    ),
                    onPressed: () {
                      _safeSetState(() {
                        _isDarkMode = !_isDarkMode;
                        if (_isDarkMode) {
                          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
                        } else {
                          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
                        }
                      });
                    },
                  ),
                ],
              )
            : null,
        body: GestureDetector(
          onTap: () {
            _safeSetState(() {
              _isToolbarVisible.value = !_isToolbarVisible.value;
              if (!_isToolbarVisible.value) {
                _isSearching = false; // Hide search when toolbar is hidden
              }
            });
          },
          child: Stack(
            children: [
              if (_isLoading)
                Container(
                  color: backgroundColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _loadingProgress > 0 && _loadingProgress < 100 ? _loadingProgress / 100 : null,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'کتێبەکە دەکرێتەوە... ${_loadingProgress.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_cachedPdfData != null || _isPdfLoadedFromFile) // Check for both in-memory and file-streamed
                Container(
                  color: Colors.white,
                  child: ColorFiltered(
                    colorFilter: _isDarkMode
                        ? const ColorFilter.matrix([
                            -1, 0, 0, 0, 255, // Red
                            0, -1, 0, 0, 255, // Green
                            0, 0, -1, 0, 255, // Blue
                            0, 0, 0, 1, 0, // Alpha
                          ])
                        : const ColorFilter.matrix([
                            1, 0, 0, 0, 0, // Red
                            0, 1, 0, 0, 0, // Green
                            0, 0, 1, 0, 0, // Blue
                            0, 0, 0, 1, 0, // Alpha
                          ]),
                    child: _cachedPdfData != null
                        ? SfPdfViewer.memory(
                            _cachedPdfData!,
                            controller: _pdfViewerController,
                            onPageChanged: (PdfPageChangedDetails details) {
                              _safeSetState(() {
                                _currentPage = details.newPageNumber - 1;
                              });
                            },
                            pageLayoutMode: PdfPageLayoutMode.single,
                            scrollDirection: PdfScrollDirection.vertical,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                            enableDoubleTapZooming: true,
                            enableTextSelection: true,
                            initialZoomLevel: 1.0,
                            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                              if (!_isDisposed && mounted) {
                                _safeSetState(() {
                                  _totalPages = details.document.pages.count;
                                  _isLoading = false; // Ensure loading is off after document loads
                                });
                              }
                            },
                            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                              if (!_isDisposed && mounted) {
                                _safeSetState(() {
                                  _isLoading = false;
                                });
                                _showSnackBar('Error: Failed to load PDF from memory. The file might be corrupted.');
                              }
                            },
                          )
                        : SfPdfViewer.network( // This handles both original network and local file streaming for large files
                            widget.url, // Still use original URL, SfPdfViewer handles internal caching/streaming
                            controller: _pdfViewerController,
                            onPageChanged: (PdfPageChangedDetails details) {
                              _safeSetState(() {
                                _currentPage = details.newPageNumber - 1;
                              });
                            },
                            pageLayoutMode: PdfPageLayoutMode.single,
                            scrollDirection: PdfScrollDirection.vertical,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                            enableDoubleTapZooming: true,
                            enableTextSelection: true,
                            initialZoomLevel: 1.0,
                            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                              if (!_isDisposed && mounted) {
                                _safeSetState(() {
                                  _totalPages = details.document.pages.count;
                                  _isLoading = false; // Ensure loading is off after document loads
                                });
                              }
                            },
                            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                              if (!_isDisposed && mounted) {
                                _safeSetState(() {
                                  _isLoading = false;
                                });
                                _showSnackBar('Error: Failed to load PDF. The file might be too large or there was a network issue.');
                              }
                            },
                          ),
                  ),
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'کردنەوەی کتێب سەرکەوتوو نەبوو! تکایە هەوڵ بدەرەوە',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadPdf,
                        child: const Text('دووبارە'),
                      ),
                    ],
                  ),
                ),

              if (_isToolbarVisible.value) // Search bar is part of the toolbar visibility
                Positioned(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _isSearching ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !_isSearching,
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(color: onSurfaceColor),
                                    decoration: InputDecoration(
                                      hintText: 'گەڕان بۆ کتێب...',
                                      hintStyle: TextStyle(color: onSurfaceColorMuted),
                                      filled: true,
                                      fillColor: isDark ? const Color(0xFF3D3D3D) : Theme.of(context).cardColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: primaryColor),
                                      ),
                                      prefixIcon: Icon(Icons.search, color: onSurfaceColorMuted),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.clear, color: onSurfaceColorMuted),
                                        onPressed: () {
                                          _searchController.clear();
                                          _handleSearch('');
                                        },
                                      ),
                                    ),
                                    onChanged: _handleSearch,
                                  ),
                                ),
                                if (_searchResult.hasResult && _searchResult.totalInstanceCount > 0) ...[
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${_currentSearchIndex + 1}/${_searchResult.totalInstanceCount}',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_upward, color: primaryColor),
                                    style: IconButton.styleFrom(
                                      backgroundColor: primaryColor.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _searchResult.hasResult ? _jumpToPreviousSearchResult : null,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_downward, color: primaryColor),
                                    style: IconButton.styleFrom(
                                      backgroundColor: primaryColor.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _searchResult.hasResult ? _jumpToNextSearchResult : null,
                                  ),
                                ],
                              ],
                            ),
                            if (_searchResult.hasResult && _searchResult.totalInstanceCount == 0 && _searchController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'No matches found for "${_searchController.text}"',
                                  style: TextStyle(
                                    color: onSurfaceColorMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else if (_searchResult.hasResult && _searchResult.totalInstanceCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Found ${_searchResult.totalInstanceCount} matches',
                                  style: TextStyle(
                                    color: onSurfaceColorMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isToolbarVisible.value)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${_currentPage + 1}',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _totalPages > 0
                                    ? SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: primaryColor,
                                          inactiveTrackColor: primaryColor.withOpacity(0.2),
                                          thumbColor: primaryColor,
                                          overlayColor: primaryColor.withOpacity(0.1),
                                        ),
                                        child: Slider(
                                          value: (_currentPage + 1).toDouble(),
                                          min: 1,
                                          max: _totalPages.toDouble(),
                                          onChanged: (value) {
                                            _jumpToPage(value.toInt());
                                          },
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          'پەڕەکە دەکرێتەوە...',
                                          style: TextStyle(
                                            color: onSurfaceColor,
                                          ),
                                        ),
                                      ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '$_totalPages',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: _currentPage > 0
                                      ? primaryColor
                                      : onSurfaceColorMuted,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: _currentPage > 0
                                      ? primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _currentPage > 0
                                    ? () {
                                        _pdfViewerController.previousPage();
                                      }
                                    : null,
                              ),
                              const SizedBox(width: 24),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: _currentPage < _totalPages - 1
                                      ? primaryColor
                                      : onSurfaceColorMuted,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: _currentPage < _totalPages - 1
                                      ? primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _currentPage < _totalPages - 1
                                    ? () {
                                        _pdfViewerController.nextPage();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}