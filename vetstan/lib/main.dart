import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'providers/notification_provider.dart';

import 'settings.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/font_size_provider.dart';
import 'providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import 'pages/favorites_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';
import 'pages/drugs.dart';
import 'pages/diseases.dart';
import 'pages/terminology.dart';
import 'pages/drug_details_page.dart';
import 'pages/disease_details_page.dart';
import 'pages/terminology_details_page.dart';
import 'pages/books.dart';
import 'pages/instruments_page.dart';
import 'pages/normal_ranges_page.dart';
import 'pages/slides.dart';
import 'utils/page_transition.dart';
import 'models/disease.dart';
import 'models/word.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'services/sync_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load SharedPreferences instance to avoid multiple async calls later
  await SharedPreferences.getInstance();

  // Initialize providers
  final notificationProvider = NotificationProvider();

  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationProvider>.value(value: notificationProvider),
           ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    try {
      final SyncService syncService = SyncService();
      await syncService.initializeApp();
    } catch (e) {
      print('Cache initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Run the app with providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyAppContent(),
    );
  }
}

class MyAppContent extends StatelessWidget {
  const MyAppContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: languageProvider.translate('app_name'),
      locale: languageProvider.currentLocale,
      theme: themeProvider.theme.copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'IQ'), // Using Arabic as fallback for RTL support
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // If the locale is Kurdish, use Arabic as the fallback for RTL support
        if (locale?.languageCode == 'ku') {
          return const Locale('ar', 'IQ');
        }
        // Default to English
        return const Locale('en', 'US');
      },
      builder: (context, child) {
        final fontSizeProvider = Provider.of<FontSizeProvider>(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: fontSizeProvider.fontSize,
          ),
          child: Directionality(
            textDirection: languageProvider.currentLocale.languageCode == 'ku'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  String _selectedFilter = 'All'; // Add this line for filter state

  int _selectedIndex = 2;
  bool _showAllItems = false;

  Widget _currentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const FavoritesPage();
      case 1:
        return const HistoryPage();
      case 2:
        return _buildHomeContent();
      case 3:
        return const BooksPage();
      case 4:
        return const ProfilePage();
      case 5:
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // App Bar
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context).theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            // Mark notifications as read when icon is pressed
                            notificationProvider.resetUnreadCount();
                          },
                          color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          iconSize: 24,
                        ),
                      ),
                      if (notificationProvider.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Provider.of<ThemeProvider>(context).theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notificationProvider.unreadCount > 9 ? '9+' : '${notificationProvider.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              // Force LTR direction for app title to ensure '+' stays at the end
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  'VET DICT+',  // or use languageProvider.translate('app_name')
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      createRoute(
                        const SettingsPage(),
                      ),
                    );
                  },
                  color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                ),
              ),
            ],
          ),
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSearchBar(),
        ),
        // Hero Section
        Container(
          margin: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            minHeight: 180,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Provider.of<ThemeProvider>(context).theme.colorScheme.primary,
                Provider.of<ThemeProvider>(context).theme.colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).theme.scaffoldBackgroundColor
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Provider.of<LanguageProvider>(context)
                          .translate('Welcome to Vet Dict+'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Provider.of<LanguageProvider>(context).translate(
                          'One of the best veterinary dictionary'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Provider.of<ThemeProvider>(context).theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        Provider.of<LanguageProvider>(context).translate('get start'),
                        style: TextStyle(
                          color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Feature Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: [
                    ..._buildFeatureItems(),
                    if (!_showAllItems) _buildShowMoreItem(),
                  ],
                ),
              );
            },
          ),
        ),
        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionItem(Icons.share,
                  Provider.of<LanguageProvider>(context).translate('share'), Colors.green),
              _buildActionItem(Icons.star_border,
                  Provider.of<LanguageProvider>(context).translate('rate'), Colors.amber),
              _buildActionItem(Icons.info_outline,
                  Provider.of<LanguageProvider>(context).translate('about'), Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatureItems() {
    final List<Map<String, dynamic>> allFeatures = [
      {
        'icon': 'Drugs.png',
        'title': 'drugs',
        'color': const Color(0xFF2563EB)
      },
      {
        'icon': 'Diseases.png',
        'title': 'diseases',
        'color': const Color(0xFF16A34A)
      },
      {
        'icon': 'Terminology.png',
        'title': 'terminology',
        'color': const Color(0xFFEAB308)
      },
      {
        'icon': 'tests.png',
        'title': 'tests',
        'color': const Color(0xFFDB2777)
      },
      {
        'icon': 'slide.png',
        'title': 'slides',
        'color': const Color(0xFF475569)
      },
      {
        'icon': 'Normalrange.png',
        'title': 'normal range',
        'color': const Color(0xFF0891B2)
      },
      {
        'icon': 'insturments.png',
        'title': 'instruments',
        'color': const Color(0xFF7C3AED)
      },
      {
        'icon': 'Note.png',
        'title': 'notes',
        'color': const Color(0xFFDC2626)
      },
      {
        'icon': 'Haematology.png',
        'title': 'haematology',
        'color': const Color(0xFFEF4444)
      },
      {
        'icon': 'Serology.png',
        'title': 'serology',
        'color': const Color(0xFF10B981)
      },
      {
        'icon': 'Endocrinology.png',
        'title': 'endocrinology',
        'color': const Color(0xFF6366F1)
      },
      {
        'icon': 'Biochemistry.png',
        'title': 'biochemistry',
        'color': const Color(0xFFF59E0B)
      },
      {
        'icon': 'Bacteriology.png',
        'title': 'bacteriology',
        'color': const Color(0xFF8B5CF6)
      },
      {
        'icon': 'Autoimmunity.png',
        'title': 'autoimmunity',
        'color': const Color(0xFFEC4899)
      },
      {
        'icon': 'Genetics.png',
        'title': 'genetics',
        'color': const Color(0xFF14B8A6)
      },
      {
        'icon': 'pills_14705111.png',
        'title': 'drugs',
        'color': const Color(0xFF00B4A2)
      },
      {
        'icon': 'flask_8385644.png',
        'title': 'settings',
        'color': const Color(0xFF2563EB)
      },
      {
        'icon': 'book_14705111.png',
        'title': 'books',
        'color': const Color(0xFF14B8A6)
      },
    ];

    // Determine how many items to show
    final itemsToShow = _showAllItems ? allFeatures.length : 5;
    final displayedFeatures = allFeatures.take(itemsToShow).toList();

    return displayedFeatures.map((feature) => _buildFeatureItem(
        feature['icon'] as String,
        feature['title'] as String,
        feature['color'] as Color,
        inBottomSheet: false)).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      // Initialize empty lists
      final drugs = [];
      final diseases = [];
      final terms = [];
      final normalRanges = [];

      // Update UI with empty data
      if (!mounted) return;
      setState(() {
        _filteredItems = [...drugs, ...diseases, ...terms, ...normalRanges];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _filteredItems = [];
      });
    }
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = [];
      });
      _removeOverlay();
      return;
    }

    setState(() {
      _filteredItems = _allItems.where((item) {
        final name = (item['name'] ?? '').toLowerCase();
        final kurdish = (item['kurdish'] ?? '').toLowerCase();
        final arabic = (item['arabic'] ?? '').toLowerCase();
        final searchQuery = query.toLowerCase();

        // Apply category filter
        if (_selectedFilter != 'All') {
          final itemType = item['type']?.toLowerCase() ?? '';
          final filterType = _selectedFilter.toLowerCase();
          if (filterType == 'drugs' && itemType != 'drug' ||
              filterType == 'diseases' && itemType != 'disease' ||
              filterType == 'terminology' && itemType != 'term' ||
              filterType == 'normal ranges' && itemType != 'normal_range') { 
            return false;
          }
        }

        return name.contains(searchQuery) || 
               kurdish.contains(searchQuery) || 
               arabic.contains(searchQuery);
      }).toList();
    });
    _showSearchResults();
  }

  void _showSearchResults() {
    _removeOverlay();

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
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context).theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    leading: Icon(_getIconForType(item['type'])),
                    title: Text(item['name']),
                    subtitle: Text(_getSubtitleForItem(item)),
                    onTap: () {
                      _removeOverlay();
                      _searchController.clear();
                      _navigateToDetails(item);
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'drug':
        return Icons.medical_services_outlined;
      case 'disease':
        return Icons.healing_outlined;
      case 'term':
        return Icons.book_outlined;
      case 'instrument':
        return Icons.medical_services_outlined;
      case 'normal_range': 
        return Icons.list_alt_outlined; 
      default:
        return Icons.search;
    }
  }

  String _getSubtitleForItem(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'drug':
        return item['category'] ?? 'Drug';
      case 'disease':
        return item['kurdish'] ?? item['category'] ?? 'Disease';
      case 'term':
        return item['kurdish'] ?? item['arabic'] ?? 'Term';
      case 'instrument':
        return item['category'] ?? 'Instrument';
      case 'normal_range': 
        return item['species'] ?? item['category'] ?? 'Normal Range'; 
      default:
        return '';
    }
  }

  void _navigateToDetails(Map<String, dynamic> item) {
    if (item['type'] == 'drug') {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => DrugDetailsPage(drug: item),
      ));
    } else if (item['type'] == 'disease') {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => DiseaseDetailsPage(
          disease: Disease(
            id: item['id'],
            name: item['name'],
            cause: item['cause'],
            control: item['control'],
            kurdish: item['kurdish'],
            symptoms: item['symptoms'],
            category: item['category'],
            imageUrl: item['imageUrl'] ?? '',
          ),
        ),
      ));
    } else if (item['type'] == 'terminology') {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => TerminologyDetailsPage(
          terminology: Word(
            id: item['id'],
            name: item['name'],
            kurdish: item['kurdish'],
            arabic: item['arabic'],
            description: item['description'],
          ),
        ),
      ));
    } else if (item['type'] == 'normal_range') { 
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => const NormalRangesPage(),
      ));
    } else if (item['type'] == 'instrument') {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => const InstrumentsPage(),
      ));
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSearchBar() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context).theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Provider.of<ThemeProvider>(context).theme.colorScheme.onSurface
                    .withOpacity(0.12)
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
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: Provider.of<LanguageProvider>(context).translate('search'),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey,
                  ),
                ),
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  _filterItems('');
                },
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey,
              ),
            Container(
              height: 24,
              width: 1,
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.2),
              margin: EdgeInsets.symmetric(horizontal: 8),
            ),
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey,
              ),
              onPressed: () => _showFilterOptions(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'All');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('All', Icons.all_inclusive, Colors.blue),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Drugs');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('Drugs', Icons.medication, Colors.green),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Diseases');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('Diseases', Icons.medical_services, Colors.orange),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Terminology');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('Terminology', Icons.menu_book, Colors.purple),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Instruments');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('Instruments', Icons.medical_services_outlined, Colors.pink),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Normal Ranges');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('Normal Ranges', Icons.list_alt_outlined, Colors.cyan.shade700), 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String text, IconData icon, Color color) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          if (_selectedFilter == text)
            Icon(
              Icons.check_circle,
              color: color,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(dynamic icon, String title, Color color,
      {bool inBottomSheet = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(
        icon,
        size: 32,
        color: color,
      );
    } else if (icon is String) {
      iconWidget = Image.asset(
        'assets/Icons/$icon',
        width: 32,
        height: 32,
        color: color,
      );
    } else {
      iconWidget = const SizedBox(); // Fallback empty widget
    }

    return InkWell(
      onTap: () {
        if (title == 'drugs') {
          Navigator.push(
            context,
            createRoute(const DrugsPage()),
          );
        } else if (title == 'diseases') {
          Navigator.push(
            context,
            createRoute(const DiseasesPage()),
          );
        } else if (title == 'terminology') {
          Navigator.push(
            context,
            createRoute(const TerminologyPage()),
          );
        } else if (title == 'tests') {
          _showTestsBottomSheet();
        } else if (title == 'slides') {
          _showSlidesBottomSheet();
        } else if (title == 'books') {
          Navigator.push(
            context,
            createRoute(const BooksPage()),
          );
        } else if (title == 'normal range') { 
          Navigator.push(context, createRoute(const NormalRangesPage())); 
        } else if (title == 'instruments') {
          Navigator.push(
            context,
            createRoute(const InstrumentsPage()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? (inBottomSheet
                  ? themeProvider.theme.colorScheme.surface
                  : themeProvider.theme.colorScheme.surface)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: iconWidget,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    languageProvider.translate(title),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? color.withOpacity(0.2)
                : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          languageProvider.translate(label),
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.87)
                : const Color(0xFF475569),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildShowMoreItem() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final Color moreColor = Colors.blue;
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? themeProvider.theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showMoreBottomSheet();
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: moreColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.more_horiz,
                        color: moreColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      languageProvider.translate('More'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: themeProvider.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  languageProvider.translate('all features'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildFeatureItem('Drugs.png', 'drugs',
                        const Color(0xFF2563EB),
                        inBottomSheet: true),
                    _buildFeatureItem('Diseases.png', 'diseases',
                        const Color(0xFF16A34A),
                        inBottomSheet: true),
                    _buildFeatureItem('Terminology.png', 'terminology',
                        const Color(0xFFEAB308),
                        inBottomSheet: true),
                    _buildFeatureItem('tests.png', 'tests',
                        const Color(0xFFDB2777),
                        inBottomSheet: true),
                    _buildFeatureItem('slide.png', 'slides',
                        const Color(0xFF475569),
                        inBottomSheet: true),
                    _buildFeatureItem('Normalrange.png', 'normal range',
                        const Color(0xFF0891B2),
                        inBottomSheet: true),
                    _buildFeatureItem('insturments.png', 'instruments',
                        const Color(0xFF7C3AED),
                        inBottomSheet: true),
                    _buildFeatureItem(
                        'Note.png', 'notes', const Color(0xFFDC2626),
                        inBottomSheet: true),
                    _buildFeatureItem(
                        'books.png', 'books', const Color.fromARGB(255, 117, 25, 203),
                        inBottomSheet: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSlidesBottomSheet() {
    final List<Map<String, dynamic>> slideCategories = [
      {
        'name': 'Urin slide',
        'icon': 'Urinslide.png',
        'type': 'Urine',
      },
      {
        'name': 'Stool slide',
        'icon': 'Stoolslide.png',
        'type': 'Stool',
      },
      {
        'name': 'Others',
        'icon': Icons.more_horiz_outlined,
        'type': 'Other',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final languageProvider = Provider.of<LanguageProvider>(context);

        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            color: themeProvider.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  languageProvider.translate('Slide Categories'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: slideCategories.length,
                  itemBuilder: (context, index) {
                    final category = slideCategories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? themeProvider.theme.colorScheme.surface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                themeProvider.isDarkMode ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SlidesPage(initialCategory: category['type']),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B4A2).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: category['icon'] is IconData
                                    ? Icon(
                                        category['icon'] as IconData,
                                        color: const Color(0xFF00B4A2),
                                        size: 28,
                                      )
                                    : Image.asset(
                                        'assets/Icons/${category['icon']}',
                                        color: const Color(0xFF00B4A2),
                                        width: 28,
                                        height: 28,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  category['name'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTestsBottomSheet() {
    final List<Map<String, dynamic>> testCategories = [
      {
        'name': 'Haematology',
        'icon': 'Haematology.png',
      },
      {
        'name': 'Serology',
        'icon': 'Serology.png',
      },
      {
        'name': 'Endocrinology',
        'icon': 'Endocrinology.png',
      },
      {
        'name': 'Biochemistry',
        'icon': 'Biochemistry.png',
      },
      {
        'name': 'Bacteriology',
        'icon': 'Bacteriology.png',
      },
      {
        'name': 'Autoimmunity',
        'icon': 'Autoimmunity.png',
      },
      {
        'name': 'Genetics',
        'icon': 'Genetics.png',
      },
      {
        'name': 'Others',
        'icon': Icons.more_horiz_outlined,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final languageProvider = Provider.of<LanguageProvider>(context);

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: themeProvider.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  languageProvider.translate('Test Categories'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: testCategories.length,
                  itemBuilder: (context, index) {
                    final category = testCategories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? themeProvider.theme.colorScheme.surface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                themeProvider.isDarkMode ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Handle category selection
                            Navigator.pop(context);
                            // Add navigation to specific test category page here
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B4A2).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: category['icon'] is IconData
                                    ? Icon(
                                        category['icon'] as IconData,
                                        color: const Color(0xFF00B4A2),
                                        size: 28,
                                      )
                                    : Image.asset(
                                        'assets/Icons/${category['icon']}',
                                        color: const Color(0xFF00B4A2),
                                        width: 28,
                                        height: 28,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  category['name'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: _currentScreen(),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          decoration: BoxDecoration(
            color: themeProvider.theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              ),
            ],
          ),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: themeProvider.theme.colorScheme.primary,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.7)
                : themeProvider.theme.colorScheme.primary,
            tabs: [
              GButton(
                icon: Icons.favorite_rounded,
                text: languageProvider.translate('favourites'),
              ),
              GButton(
                icon: Icons.history_rounded,
                text: languageProvider.translate('history'),
              ),
              GButton(
                icon: Icons.home_rounded,
                text: languageProvider.translate('home'),
              ),
              GButton(
                icon: Icons.menu_book_rounded,
                text: languageProvider.translate('books'),
              ),
              GButton(
                icon: Icons.person_rounded,
                text: languageProvider.translate('profile'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

class Drug {
  final String id;
  final String name;
  final String otherInfo;
  final String sideEffect;
  final String usage;
  final String category;
  final String imageUrl;

  Drug({
    required this.id,
    required this.name,
    required this.otherInfo,
    required this.sideEffect,
    required this.usage,
    required this.category,
    required this.imageUrl,
  });
}