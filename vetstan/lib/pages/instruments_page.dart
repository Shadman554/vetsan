import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../models/instrument.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

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
      final jsonString = await rootBundle.loadString('assets/data/instruments.json');
      final jsonData = json.decode(jsonString);
      final instruments = (jsonData['instruments'] as List)
          .map((item) => Instrument(
                id: item['id'],
                nameEn: item['name_en'],
                nameKu: item['name_ku'],
                imagePath: item['image_path'],
                descriptionEn: item['description_en'],
                descriptionKu: item['description_ku'],
              ))
          .toList();

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
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isEnglish = languageProvider.currentLocale.languageCode == 'en';
    setState(() {
      _filteredInstruments = _allInstruments
          .where((instrument) =>
              instrument.getName(isEnglish).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: PhotoView(
                  imageProvider: AssetImage(imagePath),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
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
    final isEnglish = languageProvider.currentLocale.languageCode == 'en';
    
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
        title: Text(
          languageProvider.translate('instruments'),
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? themeProvider.theme.colorScheme.onSurface
                : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [], // Remove the language button since it's in settings
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
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
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: languageProvider.translate('search_instruments'),
                hintStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: themeProvider.isDarkMode
                      ? Colors.grey[600]
                      : Colors.grey[400],
                ),
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
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _allInstruments.isEmpty
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            )
          : _filteredInstruments.isEmpty
            ? const Center(child: Text('No instruments found'))
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
                                            imageProvider: AssetImage(instrument.imagePath),
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
                                          ),
                                          Positioned.fill(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _showFullScreenImage(context, instrument.imagePath),
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
                                    child: Image.asset(
                                      instrument.imagePath,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => _showFullScreenImage(context, instrument.imagePath),
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
                                        child: Text(
                                          instrument.getName(isEnglish),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: themeProvider.isDarkMode 
                                                ? Colors.white 
                                                : Theme.of(context).primaryColor,
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
                                      firstChild: Text(
                                        instrument.getDescription(isEnglish),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkMode 
                                              ? Colors.grey[300]
                                              : Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      secondChild: Text(
                                        instrument.getDescription(isEnglish),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkMode 
                                              ? Colors.grey[300]
                                              : Colors.grey[600],
                                          height: 1.5,
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
    );
  }
}
