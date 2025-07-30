import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../models/slide.dart';

class SlidesPage extends StatefulWidget {
  final String initialCategory;
  
  const SlidesPage({
    Key? key,
    required this.initialCategory,
  }) : super(key: key);

  @override
  _SlidesPageState createState() => _SlidesPageState();
}

class _SlidesPageState extends State<SlidesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Slide> _filteredSlides = [];
  List<Slide> _allSlides = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSlides() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final apiService = ApiService();
      List<Slide> slides;

      switch (widget.initialCategory.toLowerCase()) {
        case 'urine':
          slides = await apiService.fetchUrineSlides();
          break;
        case 'stool':
          slides = await apiService.fetchStoolSlides();
          break;
        case 'other':
        default:
          slides = await apiService.fetchOtherSlides();
          break;
      }

      if (mounted) {
        setState(() {
          _allSlides = slides;
          _filteredSlides = List.from(_allSlides);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _filterSlides(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSlides = List.from(_allSlides);
      } else {
        _filteredSlides = _allSlides
            .where((slide) =>
                slide.name.toLowerCase().contains(query.toLowerCase()) ||
                slide.species.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

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
            '${widget.initialCategory} سلایدەکان',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? themeProvider.theme.colorScheme.onSurface
                  : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'NRT',
            ),
          ),
        ),
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
            child: Directionality(
              textDirection: languageProvider.textDirection,
              child: TextField(
                controller: _searchController,
                onChanged: _filterSlides,
                textDirection: languageProvider.textDirection,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontFamily: 'NRT',
                ),
                decoration: InputDecoration(
                  hintText: 'گەڕان لە سلایدەکان...',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[400],
                    fontFamily: 'NRT',
                  ),
                  suffixIcon: languageProvider.isRTL ? Icon(
                    Icons.search,
                    color: themeProvider.isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ) : null,
                  prefixIcon: !languageProvider.isRTL ? Icon(
                    Icons.search,
                    color: themeProvider.isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ) : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: themeProvider.theme.colorScheme.primary,
                size: 50,
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Directionality(
                        textDirection: languageProvider.textDirection,
                        child: Text(
                          'هەڵەیەک ڕوویدا لە بارکردنی سلایدەکان',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontSize: 16,
                            fontFamily: 'NRT',
                          ),
                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSlides,
                        child: Directionality(
                          textDirection: languageProvider.textDirection,
                          child: Text(
                            'هەوڵدانەوە',
                            style: TextStyle(
                              fontFamily: 'NRT',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredSlides.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: themeProvider.isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Directionality(
                            textDirection: languageProvider.textDirection,
                            child: Text(
                              'هیچ سلایدێک نەدۆزرایەوە',
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                                fontSize: 18,
                                fontFamily: 'NRT',
                              ),
                              textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      itemCount: _filteredSlides.length,
                      itemBuilder: (context, index) {
                        final slide = _filteredSlides[index];
                        return _buildSlideItem(context, slide, themeProvider, languageProvider);
                      },
                    ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'NRT',
              ),
            ),
          ),
          body: Center(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              initialScale: PhotoViewComputedScale.contained,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.white,
                  size: 40,
                ),
              ),
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlideItem(
      BuildContext context, Slide slide, ThemeProvider themeProvider, LanguageProvider languageProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: themeProvider.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showFullScreenImage(context, slide.imageUrl, slide.name);
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Hero(
                      tag: slide.id,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: slide.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            child: Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: themeProvider.theme.colorScheme.primary,
                                size: 30,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: themeProvider.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Directionality(
                  textDirection: languageProvider.textDirection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        slide.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                          fontFamily: 'NRT',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'جۆری ئاژەڵ: ${slide.species}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontFamily: 'NRT',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
