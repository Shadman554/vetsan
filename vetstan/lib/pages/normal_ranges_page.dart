import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/normal_range.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class NormalRangesPage extends StatefulWidget {
  const NormalRangesPage({Key? key}) : super(key: key);

  @override
  _NormalRangesPageState createState() => _NormalRangesPageState();
}

class _NormalRangesPageState extends State<NormalRangesPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSpecies;
  String _searchQuery = '';
  List<NormalRange> _normalRanges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNormalRanges();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNormalRanges() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _normalRanges = [
        NormalRange(
          id: '1',
          name: 'Red Blood Cells (RBC)',
          unit: 'million/µL',
          minValue: '5.5',
          maxValue: '8.5',
          notes: 'Normal range for red blood cells in dogs',
          category: 'Blood',
          species: 'Dog',
        ),
        NormalRange(
          id: '2',
          name: 'White Blood Cells (WBC)',
          unit: 'thousand/µL',
          minValue: '5.5',
          maxValue: '19.5',
          notes: 'Normal range for white blood cells in cats',
          category: 'Blood',
          species: 'Cat',
        ),
        // Add more sample data as needed
      ];
      _isLoading = false;
    });
  }

  // Group ranges by name and category
  Map<String, Map<String, List<NormalRange>>> get _groupedRanges {
    final Map<String, Map<String, List<NormalRange>>> grouped = {};
    
    for (final range in _normalRanges) {
      final key = '${range.name}::${range.category ?? ''}';
      if (!grouped.containsKey(key)) {
        grouped[key] = {};
      }
      final species = range.species ?? 'Unknown';
      if (!grouped[key]!.containsKey(species)) {
        grouped[key]![species] = [];
      }
      grouped[key]![species]!.add(range);
    }
    
    return grouped;
  }
  
  List<MapEntry<String, Map<String, List<NormalRange>>>> get _filteredRanges {
    return _groupedRanges.entries.where((entry) {
      if (entry.value.isEmpty || entry.value.values.first.isEmpty) return false;
      
      final firstRange = entry.value.values.first.first;
      final matchesSearch = _searchQuery.isEmpty ||
          firstRange.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (firstRange.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesCategory = _selectedCategory == null ||
          firstRange.category?.toLowerCase() == _selectedCategory?.toLowerCase();
      final matchesSpecies = _selectedSpecies == null ||
          entry.value.keys.any((species) => 
              species.toLowerCase().contains(_selectedSpecies!.toLowerCase()));
              
      return matchesSearch && matchesCategory && matchesSpecies;
    }).toList();
  }

  List<String> get _categories {
    final categories = _normalRanges
        .map((range) => range.category)
        .whereType<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  List<String> get _speciesList {
    final species = _normalRanges
        .map((range) => range.species)
        .whereType<String>()
        .toSet()
        .toList();
    species.sort();
    return species;
  }
  
  // Helper method to build filter chips
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onDeleted,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(
              Icons.close,
              size: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Build the search bar with filter button
  Widget _buildSearchBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Provider.of<LanguageProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final iconColor = isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: themeProvider.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? themeProvider.theme.colorScheme.onSurface.withOpacity(0.12)
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
              color: iconColor,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'گەڕان بە نۆرماڵ رێژەکان...',
                hintStyle: TextStyle(
                  color: iconColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.close,
                color: iconColor,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
          Container(
            height: 24,
            width: 1,
            color: isDarkMode
                ? Colors.white.withOpacity(0.12)
                : Colors.grey.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedCategory != null || _selectedSpecies != null
                  ? Colors.amber
                  : iconColor,
            ),
            onPressed: () => _showFilterOptions(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // Helper method to build table header cells
  Widget _buildTableHeaderCell(String text, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Helper method to build table cells
  Widget _buildTableCell(String text, ThemeProvider themeProvider, {bool isFirstColumn = false, bool isSingleValue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      alignment: isFirstColumn ? Alignment.centerLeft : Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          fontSize: 14,
          fontWeight: isSingleValue ? FontWeight.bold : null,
        ),
        textAlign: isFirstColumn ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? themeProvider.theme.scaffoldBackgroundColor
          : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 4,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDarkMode
            ? themeProvider.theme.appBarTheme.backgroundColor
            : themeProvider.theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode
                ? themeProvider.theme.colorScheme.onSurface
                : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'نۆرماڵ رێژەکان',
          style: TextStyle(
            color: isDarkMode
                ? themeProvider.theme.colorScheme.onSurface
                : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(context),
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
          : _filteredRanges.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.balance, // A suitable icon for normal ranges
                        size: 80,
                        color: themeProvider.isDarkMode
                            ? Colors.grey[700]
                            : Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'هیچ نۆرماڵ رێژەیەک نەدۆزرایەوە',
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
                  child: Column(
                    children: [
                      if (_selectedCategory != null || _selectedSpecies != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فیلتەرە چالاکەکان',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                                  if (_selectedCategory != null)
                                    _buildFilterChip(
                                      context,
                                      _selectedCategory!,
                                      Icons.category_outlined,
                                      () => setState(() => _selectedCategory = null),
                                    ),
                                  if (_selectedSpecies != null)
                                    _buildFilterChip(
                                      context,
                                      _selectedSpecies!,
                                      Icons.pets_outlined,
                                      () => setState(() => _selectedSpecies = null),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredRanges.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredRanges[index];
                            final firstRange = entry.value.values.first.first;
                            final speciesEntries = entry.value.entries.toList();
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
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
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Test name
                                      Text(
                                        firstRange.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      
                                      // Category if available
                                      if (firstRange.category != null && firstRange.category!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                                          child: Text(
                                            firstRange.category!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.grey[500]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      
                                      // Species and ranges table
                                      Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(top: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.grey[800]!
                                                : Colors.grey[300]!,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Table(
                                          columnWidths: const {
                                            0: FlexColumnWidth(1.5),
                                            1: FlexColumnWidth(1),
                                            2: FlexColumnWidth(1),
                                          },
                                          border: TableBorder(
                                            horizontalInside: BorderSide(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.grey[800]!
                                                  : Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          children: [
                                            // Table header with unit
                                            TableRow(
                                              decoration: BoxDecoration(
                                                color: themeProvider.isDarkMode
                                                    ? Colors.grey[900]!
                                                    : Colors.grey[100]!,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  topRight: Radius.circular(7),
                                                ),
                                              ),
                                              children: [
                                                _buildTableHeaderCell(
                                                  'جۆر', 
                                                  themeProvider
                                                ),
                                                _buildTableHeaderCell(
                                                  firstRange.minValue.isNotEmpty && !firstRange.minValue.startsWith('<') && !firstRange.minValue.startsWith('>')
                                                      ? 'کەمترین${firstRange.unit.isNotEmpty ? '\n(${firstRange.unit})' : ''}'
                                                      : 'نرخ',
                                                  themeProvider
                                                ),
                                                if (firstRange.minValue.isNotEmpty && firstRange.maxValue.isNotEmpty && 
                                                    !firstRange.minValue.startsWith('<') && !firstRange.minValue.startsWith('>') &&
                                                    !firstRange.maxValue.startsWith('<') && !firstRange.maxValue.startsWith('>'))
                                                  _buildTableHeaderCell(
                                                    'زۆرترین${firstRange.unit.isNotEmpty ? '\n(${firstRange.unit})' : ''}',
                                                    themeProvider
                                                  )
                                                else
                                                  _buildTableHeaderCell('', themeProvider),
                                              ],
                                            ),
                                            // Table rows for each species
                                            ...speciesEntries.expand((speciesEntry) {
                                              final species = speciesEntry.key;
                                              final ranges = speciesEntry.value;
                                              return ranges.map((range) {
                                                // Check if we should show a single value instead of min/max
                                                final showSingleValue = range.minValue.isEmpty || range.maxValue.isEmpty || 
                                                                  range.minValue.startsWith('<') || range.minValue.startsWith('>') ||
                                                                  range.maxValue.startsWith('<') || range.maxValue.startsWith('>');
                                                
                                                return TableRow(
                                                  decoration: BoxDecoration(
                                                    color: themeProvider.isDarkMode
                                                        ? Color(0xFF1E1E1E)
                                                        : Colors.white,
                                                  ),
                                                  children: [
                                                    _buildTableCell(species, themeProvider, isFirstColumn: true),
                                                    if (showSingleValue)
                                                      _buildTableCell(
                                                        range.minValue.isNotEmpty ? range.minValue : range.maxValue, 
                                                        themeProvider,
                                                        isSingleValue: true
                                                      )
                                                    else
                                                      _buildTableCell(range.minValue, themeProvider),
                                                    if (!showSingleValue)
                                                      _buildTableCell(range.maxValue, themeProvider)
                                                    else
                                                      Container(), // Empty cell when showing single value
                                                  ],
                                                );
                                              });
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                      
                                      // Notes if available
                                      if (firstRange.notes != null && firstRange.notes!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12.0),
                                          child: Text(
                                            firstRange.notes!,
                                            style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[700],
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                            ),
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
                ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    Provider.of<LanguageProvider>(context, listen: false);
    
    String? newCategory = _selectedCategory;
    String? newSpecies = _selectedSpecies;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'فیلتەرکردنی رێژەکان',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // Category Filter
            _buildFilterSection(
              context: context,
              title: 'پۆل',
              value: newCategory,
              items: [null, ..._categories],
              onChanged: (value) => newCategory = value,
              displayText: (value) => value ?? 'هەموو پۆلەکان',
            ),
            const SizedBox(height: 16),
            // Species Filter
            _buildFilterSection(
              context: context,
              title: 'جۆر',
              value: newSpecies,
              items: [null, ..._speciesList],
              onChanged: (value) => newSpecies = value,
              displayText: (value) => value ?? 'هەموو جۆرەکان',
            ),
            const SizedBox(height: 24),
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = newCategory;
                    _selectedSpecies = newSpecies;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'جێبەجێکردنی فیلتەرەکان',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterSection<T>({
    required BuildContext context,
    required String title,
    required T? value,
    required List<T?> items,
    required ValueChanged<T?> onChanged,
    required String Function(T?) displayText,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              dropdownColor: isDarkMode ? const Color(0xFF3A3A3A) : Colors.white,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<T>>((T? item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayText(item),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}