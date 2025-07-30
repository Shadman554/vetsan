import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../models/instrument.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';

class InstrumentsPage extends StatefulWidget {
  const InstrumentsPage({Key? key}) : super(key: key);

  @override
  State<InstrumentsPage> createState() => _InstrumentsPageState();
}

class _InstrumentsPageState extends State<InstrumentsPage> with SingleTickerProviderStateMixin {
  final Map<int, bool> _expandedStates = {};
  late AnimationController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<Instrument> _filteredInstruments = [];
  List<Instrument> _allInstruments = [];

  @override
  void initState() {
    super.initState();
    _loadInstruments();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstruments() async {
    try {
      final apiService = ApiService();
      final instruments = await apiService.fetchAllInstruments();

      setState(() {
        _allInstruments = instruments;
        _filteredInstruments = instruments;
      });
    } catch (e) {
      debugPrint('Error loading instruments: $e');
      setState(() {
        _allInstruments = [];
        _filteredInstruments = [];
      });
    }
  }

  void _filterInstruments(String query) {
    final isEnglish = false; // Always use Kurdish
    setState(() {
      _filteredInstruments = _allInstruments
          .where((instrument) =>
              instrument.getName(isEnglish).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(imageUrl),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  loadingBuilder: (context, event) => Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = false; // Always use Kurdish
    
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Directionality(
          textDirection: languageProvider.textDirection,
          child: Text(
            'ئامێرەکان',
            style: TextStyle(
              color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
          ),
        ),
        actions: [], // Remove the language button since it's in settings
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Directionality(
            textDirection: languageProvider.textDirection,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: themeProvider.isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterInstruments,
                textDirection: languageProvider.textDirection,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  hintText: 'گەڕان بە ئامێر...',
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: languageProvider.textDirection,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: _allInstruments.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).primaryColor,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loadInstruments,
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
            : _filteredInstruments.isEmpty
              ? Center(
                  child: Directionality(
                    textDirection: languageProvider.textDirection,
                    child: Text(
                      'هیچ ئامێرێک نیە',
                      style: TextStyle(
                        fontSize: 18,
                        color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    physics: const BouncingScrollPhysics(),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    itemCount: _filteredInstruments.length,
                    itemBuilder: (context, index) {
                      final instrument = _filteredInstruments[index];
                      final isExpanded = _expandedStates[index] ?? false;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedStates[index] = !(_expandedStates[index] ?? false);
                            if (_expandedStates[index]!) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    if (isExpanded)
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(14),
                                        ),
                                        child: SizedBox(
                                          height: 300,
                                          width: double.infinity,
                                          child: Stack(
                                            children: [
                                              PhotoView(
                                                imageProvider: CachedNetworkImageProvider(instrument.imageUrl),
                                                minScale: PhotoViewComputedScale.contained,
                                                maxScale: PhotoViewComputedScale.covered * 2,
                                                backgroundDecoration: BoxDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                ),
                                                loadingBuilder: (context, event) => Center(
                                                  child: LoadingAnimationWidget.staggeredDotsWave(
                                                    color: Theme.of(context).primaryColor,
                                                    size: 40,
                                                  ),
                                                ),
                                                errorBuilder: (context, error, stackTrace) => Center(
                                                  child: Icon(
                                                    Icons.error_outline,
                                                    color: Theme.of(context).primaryColor,
                                                    size: 50,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () => _showFullScreenImage(context, instrument.imageUrl),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(14),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: instrument.imageUrl,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Shimmer.fromColors(
                                            baseColor: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                            highlightColor: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                                            child: Container(
                                              height: 200,
                                              width: double.infinity,
                                              color: Colors.white,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                            child: Icon(
                                              Icons.error_outline,
                                              color: themeProvider.isDarkMode ? Colors.white54 : Colors.grey[600],
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () => _showFullScreenImage(context, instrument.imageUrl),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.zoom_in,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Directionality(
                                              textDirection: languageProvider.textDirection,
                                              child: Text(
                                                instrument.getName(isEnglish),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: themeProvider.isDarkMode 
                                                      ? Colors.white 
                                                      : const Color(0xFF1E293B),
                                                  fontFamily: 'Inter',
                                                ),
                                                textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: themeProvider.isDarkMode 
                                                  ? Colors.white.withOpacity(0.1) 
                                                  : Theme.of(context).primaryColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: AnimatedRotation(
                                              turns: isExpanded ? 0.5 : 0,
                                              duration: const Duration(milliseconds: 300),
                                              child: Icon(
                                                Icons.expand_more,
                                                color: themeProvider.isDarkMode 
                                                    ? Colors.white 
                                                    : Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        child: AnimatedCrossFade(
                                          firstChild: Directionality(
                                            textDirection: languageProvider.textDirection,
                                            child: Text(
                                              instrument.getDescription(isEnglish),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkMode 
                                                    ? Colors.grey[300]
                                                    : Colors.grey[600],
                                                fontFamily: 'Inter',
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                                            ),
                                          ),
                                          secondChild: Directionality(
                                            textDirection: languageProvider.textDirection,
                                            child: Text(
                                              instrument.getDescription(isEnglish),
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkMode 
                                                    ? Colors.grey[300]
                                                    : Colors.grey[600],
                                                height: 1.5,
                                                fontFamily: 'Inter',
                                              ),
                                              textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                                            ),
                                          ),
                                          crossFadeState: isExpanded
                                              ? CrossFadeState.showSecond
                                              : CrossFadeState.showFirst,
                                          duration: const Duration(milliseconds: 400),
                                          firstCurve: Curves.easeOut,
                                          secondCurve: Curves.easeIn,
                                          sizeCurve: Curves.easeInOut,
                                        ),
                                      ),
                                    ],
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
        ),
      ),
    );
  }
}
