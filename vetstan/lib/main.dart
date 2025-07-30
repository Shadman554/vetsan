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
import 'providers/auth_provider.dart';
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
import 'pages/notes_page.dart';
import 'pages/about_page.dart';
import 'pages/introduction_page.dart';
import 'utils/page_transition.dart';
import 'models/drug.dart';
import 'models/disease.dart';
import 'models/word.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'services/sync_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock screen orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
          ChangeNotifierProvider(create: (_) => AuthProvider()),
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

    // Return the app content directly since providers are already created in main()
    return const MyAppContent();
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
      title: 'VET+',
      locale: languageProvider.currentLocale,
      theme: themeProvider.theme.copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      supportedLocales: const [
        Locale('ku'), // Kurdish
        Locale('en'), // English
        Locale('ar', 'IQ'), // Arabic for RTL support
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Use Arabic as the fallback for RTL support when Kurdish is selected
        if (languageProvider.currentLocale.languageCode == 'ku') {
          return const Locale('ar', 'IQ');
        }
        return languageProvider.currentLocale;
      },
      builder: (context, child) {
        final fontSizeProvider = Provider.of<FontSizeProvider>(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: fontSizeProvider.fontSize,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr, // Keep LTR layout for UI elements
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
  final FocusNode _searchFocusNode = FocusNode();
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
                  crossAxisAlignment: Provider.of<LanguageProvider>(context).isRTL 
                      ? CrossAxisAlignment.end 
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(textDirection: Provider.of<LanguageProvider>(context).textDirection,
   
                      child: Text(
                        'بەخێربێن بۆ +VET DICT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: Provider.of<LanguageProvider>(context).isRTL 
                            ? TextAlign.right 
                            : TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Directionality(textDirection: Provider.of<LanguageProvider>(context).textDirection,
   
                      child: Text(
                        'یەکێک لە باشترین فەرهەنگەکان بۆ خوێندکارانی پزیشکی ڤێتیرنەری.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.3,
                        ),
                        textAlign: Provider.of<LanguageProvider>(context).isRTL 
                            ? TextAlign.right 
                            : TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Provider.of<LanguageProvider>(context).isRTL 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            createRoute(const IntroductionPage()),
                          );
                        },
                        child: Container(
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
                          child: Directionality(
                            textDirection: Provider.of<LanguageProvider>(context).textDirection,
                            child: Text(
                              'دەستپێکردن',
                              style: TextStyle(
                                color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: Provider.of<LanguageProvider>(context).isRTL 
                                  ? TextAlign.right 
                                  : TextAlign.left,
                            ),
                          ),
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
                  'هاوبەشکردن', Colors.green),
              _buildActionItem(Icons.star_border,
                  'هەڵسەنگاندن', Colors.amber),
              _buildActionItem(Icons.info_outline,
                  'دەربارە', Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      createRoute(const AboutPage()),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatureItems() {
    final List<Map<String, dynamic>> allFeatures = [
      {
        'id': 'drugs',
        'icon': 'Drugs.png',
        'title': 'دەرمانەکان',
        'color': const Color(0xFF2563EB)
      },
      {
        'id': 'diseases',
        'icon': 'Diseases.png',
        'title': 'نەخۆشیەکان',
        'color': const Color(0xFF16A34A)
      },
      {
        'id': 'terminology',
        'icon': 'Terminology.png',
        'title': 'زاراوەکان',
        'color': const Color(0xFFEAB308)
      },
      {
        'id': 'tests',
        'icon': 'tests.png',
        'title': 'پشکنینەکان',
        'color': const Color(0xFFDB2777)
      },
      {
        'id': 'slides',
        'icon': 'slide.png',
        'title': 'سڵایدەکان',
        'color': const Color(0xFF475569)
      },
      {
        'id': 'normal_range',
        'icon': 'Normalrange.png',
        'title': 'پێوانە ئاساییەکان',
        'color': const Color(0xFF0891B2)
      },
      {
        'id': 'instruments',
        'icon': 'insturments.png',
        'title': 'کەرەستە پزیشکیەکان',
        'color': const Color(0xFF7C3AED)
      },
      {
        'id': 'notes',
        'icon': 'Note.png',
        'title': 'تێبینیەکان',
        'color': const Color(0xFFDC2626)
      },
      {
        'id': 'haematology',
        'icon': 'Haematology.png',
        'title': 'haematology',
        'color': const Color(0xFFEF4444)
      },
      {
        'id': 'serology',
        'icon': 'Serology.png',
        'title': 'serology',
        'color': const Color(0xFF10B981)
      },
      {
        'id': 'endocrinology',
        'icon': 'Endocrinology.png',
        'title': 'endocrinology',
        'color': const Color(0xFF6366F1)
      },
      {
        'id': 'biochemistry',
        'icon': 'Biochemistry.png',
        'title': 'biochemistry',
        'color': const Color(0xFFF59E0B)
      },
      {
        'id': 'bacteriology',
        'icon': 'Bacteriology.png',
        'title': 'bacteriology',
        'color': const Color(0xFF8B5CF6)
      },
      {
        'id': 'autoimmunity',
        'icon': 'Autoimmunity.png',
        'title': 'autoimmunity',
        'color': const Color(0xFFEC4899)
      },
      {
        'id': 'genetics',
        'icon': 'Genetics.png',
        'title': 'genetics',
        'color': const Color(0xFF14B8A6)
      },
      {
        'id': 'drugs_alt',
        'icon': 'pills_14705111.png',
        'title': 'drugs',
        'color': const Color(0xFF00B4A2)
      },
      {
        'id': 'settings',
        'icon': 'flask_8385644.png',
        'title': 'ڕێکخستن',
        'color': const Color(0xFF2563EB)
      },
      {
        'id': 'books',
        'icon': 'book_14705111.png',
        'title': 'کتێبەکان',
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
        id: feature['id'] as String,
        inBottomSheet: false)).toList();
  }

  @override
  void initState() {
    super.initState();
    print('HomePage initState called - fetching data...');
    _fetchAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      print('Starting to fetch data...');
      final syncService = SyncService();
      
      // Ensure cache service is initialized first
      await syncService.initializeApp();
      
      // Load data using sync service (handles both cached and API data)
      final drugsData = await syncService.loadCategoryData<Drug>('drugs');
      final diseasesData = await syncService.loadCategoryData<Disease>('diseases');
      final termsData = await syncService.loadCategoryData<Word>('dictionary');
      
      print('Raw data loaded:');
      print('- Drugs: ${drugsData.length}');
      print('- Diseases: ${diseasesData.length}');
      print('- Terms: ${termsData.length}');
      
      // Convert to Map format with type field for search
      final drugs = drugsData.map((drug) => {
        'id': drug.id,
        'name': drug.name,
        'kurdish': drug.kurdish,
        'arabic': '', // Drug model doesn't have arabic field
        'usage': drug.usage,
        'sideEffect': drug.sideEffect,
        'otherInfo': drug.otherInfo,
        'description': drug.description,
        'drugClass': drug.drugClass,
        'type': 'drug',
      }).toList();

      final diseases = diseasesData.map((disease) => {
        'id': disease.id,
        'name': disease.name,
        'kurdish': disease.kurdish,
        'arabic': '', // Disease model doesn't have arabic field
        'cause': disease.cause,
        'control': disease.control,
        'symptoms': disease.symptoms,
        'category': disease.category,
        'imageUrl': disease.imageUrl,
        'type': 'disease',
      }).toList();

      final terms = termsData.map((term) => {
        'id': term.id,
        'name': term.name,
        'kurdish': term.kurdish,
        'arabic': term.arabic,
        'description': term.description,
        'type': 'terminology',
      }).toList();

      // Combine all data and update both _allItems and _filteredItems
      if (!mounted) return;
      setState(() {
        _allItems = [...drugs, ...diseases, ...terms];
        _filteredItems = [];
      });
      
      print('Total items loaded for search: ${_allItems.length}');
    } catch (e) {
      print('Error loading data for search: $e');
      if (!mounted) return;
      setState(() {
        _allItems = [];
        _filteredItems = [];
      });
    }
  }

  void _filterItems(String query) {
    print('Search query: "$query"');
    print('Total items in _allItems: ${_allItems.length}');
    
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
          
          // Check if item matches the selected filter
          bool matchesFilter = false;
          switch (filterType) {
            case 'drugs':
              matchesFilter = itemType == 'drug';
              break;
            case 'diseases':
              matchesFilter = itemType == 'disease';
              break;
            case 'terminology':
              matchesFilter = itemType == 'terminology';
              break;
            case 'instruments':
              matchesFilter = itemType == 'instrument';
              break;
            case 'normal ranges':
              matchesFilter = itemType == 'normal_range';
              break;
            default:
              matchesFilter = true;
          }
          
          if (!matchesFilter) {
            return false;
          }
        }

        final matches = name.contains(searchQuery) || 
               kurdish.contains(searchQuery) || 
               arabic.contains(searchQuery);
        
        if (matches) {
          print('Found match: ${item['name']} (${item['type']})');
        }
        
        return matches;
      }).toList();
    });
    
    print('Filtered results: ${_filteredItems.length}');
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
      case 'terminology':
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
      case 'terminology':
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
  // Unfocus search field before navigation to prevent keyboard from showing when returning
  if (_searchFocusNode.hasFocus) {
    _searchFocusNode.unfocus();
  }
  
  if (item['type'] == 'drug') {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => DrugDetailsPage(
          drug: Drug(
            id: item['id'],
            name: item['name'],
            kurdish: item['kurdish'],
            usage: item['usage'],
            sideEffect: item['sideEffect'],
            otherInfo: item['otherInfo'],
            description: item['description'],
            drugClass: item['drugClass'],
            category: item['category'] ?? '',
            imageUrl: item['imageUrl'] ?? '',
          ),
        ),
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
        child: Directionality(
          textDirection: Provider.of<LanguageProvider>(context).textDirection,
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
                  focusNode: _searchFocusNode,
                  onChanged: _filterItems,
                  autofocus: false,
                  textDirection: Provider.of<LanguageProvider>(context).textDirection,
                  decoration: InputDecoration(
                    hintText: 'گەڕان...',
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
                    'فلتەرکردن بەپێی',
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
                    child: _buildFilterOption('هەموو', Icons.all_inclusive, Colors.blue, 'All'),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Drugs');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('دەرمانەکان', Icons.medication, Colors.green, 'Drugs'),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Diseases');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('نەخۆشیەکان', Icons.medical_services, Colors.orange, 'Diseases'),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Terminology');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('زاراوەکان', Icons.menu_book, Colors.purple, 'Terminology'),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Instruments');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('کەرەستە پزیشکیەکان', Icons.medical_services_outlined, Colors.pink, 'Instruments'),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'Normal Ranges');
                      _filterItems(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: _buildFilterOption('پێوانە ئاساییەکان', Icons.list_alt_outlined, Colors.cyan.shade700, 'Normal Ranges'), 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String text, IconData icon, Color color, String filterKey) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isSelected = _selectedFilter == filterKey;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? color.withOpacity(0.1) 
            : (isDarkMode ? Colors.black12 : Colors.grey.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: color.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Directionality(
        textDirection: languageProvider.textDirection,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(dynamic icon, String title, Color color,
      {required String id, bool inBottomSheet = false}) {
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
        // Unfocus search field before navigation to prevent keyboard from showing when returning
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
        
        if (id == 'drugs') {
          Navigator.push(
            context,
            createRoute(const DrugsPage()),
          );
        } else if (id == 'diseases') {
          Navigator.push(
            context,
            createRoute(const DiseasesPage()),
          );
        } else if (id == 'terminology') {
          Navigator.push(
            context,
            createRoute(const TerminologyPage()),
          );
        } else if (id == 'tests') {
          _showTestsBottomSheet();
        } else if (id == 'slides') {
          _showSlidesBottomSheet();
        } else if (id == 'notes') {
          Navigator.push(
            context,
            createRoute(const NotesPage()),
          );
        } else if (id == 'books') {
          Navigator.push(
            context,
            createRoute(const BooksPage()),
          );
        } else if (id == 'normal_range') { 
          Navigator.push(context, createRoute(const NormalRangesPage())); 
        } else if (id == 'instruments') {
          Navigator.push(
            context,
            createRoute(const InstrumentsPage()),
          );
        } else if (id == 'settings') {
          Navigator.push(
            context,
            createRoute(const SettingsPage()),
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
                  child: Directionality(
                    textDirection: languageProvider.textDirection,
                    child: Text(
                      title,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
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
            label,
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.87)
                  : const Color(0xFF475569),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreItem() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Provider.of<LanguageProvider>(context);
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
                      'زیاتر',
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
        Provider.of<LanguageProvider>(context);
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
                  'هەموو تایبەتمەندییەکان',
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
                    _buildFeatureItem('Drugs.png', 'دەرمانەکان',
                        const Color(0xFF2563EB),
                        id: 'drugs', inBottomSheet: true),
                    _buildFeatureItem('Diseases.png', 'نەخۆشیەکان',
                        const Color(0xFF16A34A),
                        id: 'diseases', inBottomSheet: true),
                    _buildFeatureItem('Terminology.png', 'زاراوەکان',
                        const Color(0xFFEAB308),
                        id: 'terminology', inBottomSheet: true),
                    _buildFeatureItem('tests.png', 'پشکنینەکان',
                        const Color(0xFFDB2777),
                        id: 'tests', inBottomSheet: true),
                    _buildFeatureItem('slide.png', 'سڵایدەکان',
                        const Color(0xFF475569),
                        id: 'slides', inBottomSheet: true),
                    _buildFeatureItem('Normalrange.png', 'پێوانە ئاساییەکان',
                        const Color(0xFF0891B2),
                        id: 'normal_range', inBottomSheet: true),
                    _buildFeatureItem('insturments.png', 'کەرەستە پزیشکیەکان',
                        const Color(0xFF7C3AED),
                        id: 'instruments', inBottomSheet: true),
                    _buildFeatureItem(
                        'Note.png', 'تێبینیەکان', const Color(0xFFDC2626),
                        id: 'notes', inBottomSheet: true),
                    _buildFeatureItem(
                        'books.png', 'کتێبەکان', const Color.fromARGB(255, 117, 25, 203),
                        id: 'books', inBottomSheet: true),
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
        Provider.of<LanguageProvider>(context);

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
                  'پۆلەکانی سلاید',
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
                              createRoute(
                                SlidesPage(initialCategory: category['type']),
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
        Provider.of<LanguageProvider>(context);

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
                  'پۆلەکانی تاقیکردنەوە',
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
    Provider.of<LanguageProvider>(context);

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
                text: 'دڵخوازەکان',
              ),
              GButton(
                icon: Icons.history_rounded,
                text: 'مێژوو',
              ),
              GButton(
                icon: Icons.home_rounded,
                text: 'سەرەکی',
              ),
              GButton(
                icon: Icons.menu_book_rounded,
                text: 'کتێبەکان',
              ),
              GButton(
                icon: Icons.person_rounded,
                text: 'پرۆفایل',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              // Unfocus search field to prevent keyboard from showing
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
              }
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
