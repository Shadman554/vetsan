import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import '../providers/theme_provider.dart';

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
  List<Map<String, String>> _filteredSlides = [];
  List<Map<String, String>> _allSlides = [];
  bool _isLoading = false;

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

  void _loadSlides() {
    setState(() {
      _isLoading = true;
      _allSlides = _getSlidesByCategory(widget.initialCategory);
      _filteredSlides = List.from(_allSlides);
      _isLoading = false;
    });
  }

  void _filterSlides(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSlides = List.from(_allSlides);
      } else {
        _filteredSlides = _allSlides
            .where((slide) =>
                slide['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  List<Map<String, String>> _getSlidesByCategory(String category) {
    if (category == 'Urine') {
      return [
        {
          'image': 'assets/images/urine/urine1.jpg',
          'name': 'Normal Urine Sediment',
          'species': 'Canine, Feline',
        },
        {
          'image': 'assets/images/urine/urine2.jpg',
          'name': 'Crystals in Urine',
          'species': 'Canine, Feline, Equine',
        },
        // Add more urine slides as needed
      ];
    } else if (category == 'Stool') {
      return [
        {
          'image': 'assets/images/stool/Stool test.jpg',
          'name': 'Normal Stool Sample',
          'species': 'Canine, Feline',
        },
        {
          'image': 'assets/images/stool/stool2.jpg',
          'name': 'Parasite Eggs',
          'species': 'Canine, Feline, Bovine',
        },
        // Add more stool slides as needed
      ];
    } else {
      // Other slides
      return [
        {
          'image': 'assets/images/other/other1.jpg',
          'name': 'Blood Smear',
          'species': 'All Species',
        },
        {
          'image': 'assets/images/other/other2.jpg',
          'name': 'Cytology',
          'species': 'All Species',
        },
        // Add more other slides as needed
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    // Language provider is kept for future localization

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
        title: Text(
          '${widget.initialCategory} Slides',
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? themeProvider.theme.colorScheme.onSurface
                : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
            child: TextField(
              controller: _searchController,
              onChanged: _filterSlides,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search slides...',
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: themeProvider.isDarkMode
                    ? themeProvider.theme.colorScheme.primary
                    : Colors.blue,
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
                      Text(
                        'No slides found',
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
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: _filteredSlides.length,
                  itemBuilder: (context, index) {
                    final slide = _filteredSlides[index];
                    return _buildSlideItem(context, slide, themeProvider);
                  },
                ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath, String name) {
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
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: PhotoView(
              imageProvider: AssetImage(imagePath),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              initialScale: PhotoViewComputedScale.contained,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                  ),
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
      BuildContext context, Map<String, String> slide, ThemeProvider themeProvider) {
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showFullScreenImage(context, slide['image']!, slide['name']!);
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
                      tag: slide['image']!,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          slide['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Species: ${slide['species']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
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
  }
}
