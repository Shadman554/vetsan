import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Directionality(
          textDirection: languageProvider.textDirection,
          child: Text(
            'دەربارەی',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // App Description Section
              _buildDescriptionSection(themeProvider, languageProvider),
              
              const SizedBox(height: 30),
              
              // CEO Section
              _buildCEOSection(themeProvider, languageProvider),
              
              const SizedBox(height: 30),
              
              // Support Team Section
              _buildSupportTeamSection(themeProvider, languageProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeProvider themeProvider, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? themeProvider.theme.colorScheme.surface 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: languageProvider.textDirection,
                  child: Text(
                    'دەربارەی ئەپڵیکەیشن',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'Inter',
                    ),
                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Directionality(
            textDirection: languageProvider.textDirection,
            child: RichText(
              textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: themeProvider.isDarkMode 
                      ? Colors.white.withOpacity(0.85) 
                      : Colors.grey[700],
                  fontFamily: 'Inter',
                ),
                children: [
                  const TextSpan(
                    text: '+VET DICT ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B4A2),
                    ),
                  ),
                  const TextSpan(
                    text: 'یەکەم فەرهەنگی پزیشکی پیشەیی و تەکنەلۆژی پێشکەوتووە بۆ پزیشکانی ڤێتیرنەری لە کوردستان. ئەم ئەپڵیکەیشنە بە شێوەیەکی زانستی و پیشەیی کۆمەڵێک زانیاری پزیشکی گرنگ پێشکەش دەکات:\n\n',
                  ),
                  TextSpan(
                    text: '• دەرمانەکان و بەکارهێنانیان\n',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '• نەخۆشییەکان و چارەسەرەکانیان\n',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '• زاراوە پزیشکیەکان و زانستیەکان\n',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '• کتێبە پزیشکیەکان و سەرچاوە زانستیەکان\n',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '•وە چەندین تایبەتمەندی تر...\n\n',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(
                    text: 'ئامانجمان پشتگیری پزیشکانی ڤێتیرنەریە لە کوردستان بۆ دەستگەیشتن بە زانیاری پێویست بە شێوەیەکی خێرا، ئاسان و پیشەیی لە زمانی کوردیدا.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mission Statement Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00B4A2).withOpacity(0.1),
                  const Color(0xFF00B4A2).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00B4A2).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B4A2).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF00B4A2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Directionality(
                    textDirection: languageProvider.textDirection,
                    child: Text(
                      'پێشکەوتنی پزیشکی ڤێتیرنەریە لە کوردستان لە ڕێگەی تەکنەلۆژیاوە',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00B4A2),
                        fontFamily: 'Inter',
                      ),
                      textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCEOSection(ThemeProvider themeProvider, LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? themeProvider.theme.colorScheme.surface 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: languageProvider.textDirection,
                  child: Text(
                    'بەڕێوەبەرانی پڕۆژە',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'Inter',
                    ),
                    textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          // Second CEO - Shadman Othman
          _buildCEOCard(
            name: 'شادمان عثمان',
            role: 'بەڕێوەبەری تەکنیکی و گەشەپێدەر',
            description: 'خوێندکاری پزیشکی ڤێتیرنەری - زانکۆی سلێمانی',
            color: const Color(0xFF2563EB),
            socialMedia: {
              'facebook': 'https://www.facebook.com/shadman.osman.2025',
              'viber': 'tel:+9647824961601',
            },
            themeProvider: themeProvider,
            languageProvider: languageProvider,
            imagePath: 'assets/images/persons/shadman.png',
          ),
         
          
          const SizedBox(height: 16),
           // First CEO - Haroon Mubarak
          _buildCEOCard(
            name: 'هاڕوون موبارەک',
            role: 'بەڕێوەبەر و کۆکەرەوەی زانیاری',
            description: 'خوێندکاری پزیشکی ڤێتیرنەری - زانکۆی سلێمانی',
            color: const Color(0xFF16A34A),
            socialMedia: {
              'facebook': 'https://www.facebook.com/harun.mubark.2025',
              'viber': 'tel:+9647734402627',
            },
            themeProvider: themeProvider,
            languageProvider: languageProvider,
            imagePath: 'assets/images/persons/haroon.png',
          ),
          
        ],
      ),
    );
  }

  Widget _buildSupportTeamSection(ThemeProvider themeProvider, LanguageProvider languageProvider) {
    final List<Map<String, dynamic>> supportTeam = [
      {
        'name': 'د. پاڤێڵ عمر',
        'title': 'پزیشکی ڤێتیرنەری و مامۆستای زانکۆی سلێمانی',
        'color': const Color(0xFF059669),
        'icon': Icons.medical_services,
        'imagePath': 'assets/images/persons/pavel.png',
      },
      {
        'name': 'پرۆفیسۆر د. فەرەیدوون عبدالستار',
        'title': 'پرۆفیسۆر و مامۆستای زانکۆ و ڕاگری پێشووی کۆلیژی پزیشکی ڤێتیرنەری',
        'color': const Color(0xFF7C3AED),
        'icon': Icons.school,
        'imagePath': 'assets/images/persons/faraidoon.png',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.isDarkMode 
                ? const Color(0xFF1F2937)
                : Colors.white,
            themeProvider.isDarkMode 
                ? const Color(0xFF374151)
                : const Color(0xFFFAFAFA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: themeProvider.isDarkMode 
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header Section with Enhanced Design
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEAB308).withOpacity(0.1),
                  const Color(0xFFEAB308).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: languageProvider.isRTL 
                        ? CrossAxisAlignment.end 
                        : CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: languageProvider.textDirection,
                        child: Text(
                          'هاوکاران',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            fontFamily: 'Inter',
                            letterSpacing: 0.5,
                          ),
                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection: languageProvider.textDirection,
                        child: Text(
                          'سپاسی هەریەکە لەم بەڕێزانە دەکەین کە بە چەندین شێواز هاوکارمان بوون لە بەرەوپێش بردنی ئەم پرۆژەیە',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.isDarkMode 
                                ? Colors.white.withOpacity(0.7) 
                                : Colors.grey[600],
                            fontFamily: 'Inter',
                          ),
                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Support Team Cards
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: supportTeam.map((member) => _buildEnhancedSupporterCard(
                member,
                themeProvider,
                languageProvider,
              )).toList(),
            ),
          ),
          
          // Appreciation Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFFEAB308).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Directionality(
                    textDirection: languageProvider.textDirection,
                    child: Text(
                      'سپاس بۆ هەموو ئەوانەی پشتگیری ئەم پرۆژەیەیان کردووە',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode 
                            ? Colors.white.withOpacity(0.6) 
                            : Colors.grey[600],
                        fontFamily: 'Inter',
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSupporterCard(
    Map<String, dynamic> member,
    ThemeProvider themeProvider,
    LanguageProvider languageProvider,
  ) {
    final Color memberColor = member['color'] as Color;
    final IconData memberIcon = member['icon'] as IconData;
    final List<String> achievements = (member['achievements'] as List<String>?) ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.isDarkMode 
                ? const Color(0xFF374151)
                : Colors.white,
            themeProvider.isDarkMode 
                ? const Color(0xFF4B5563)
                : const Color(0xFFFDFDFD),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: memberColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: memberColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header with Avatar and Basic Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  memberColor.withOpacity(0.08),
                  memberColor.withOpacity(0.04),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Enhanced Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: member['imagePath'] == null ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        memberColor,
                        memberColor.withOpacity(0.8),
                      ],
                    ) : null,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: memberColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: member['imagePath'] != null
                      ? ClipOval(
                          child: Image.asset(
                            member['imagePath'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      memberColor,
                                      memberColor.withOpacity(0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  memberIcon,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        )
                      : Icon(
                          memberIcon,
                          size: 32,
                          color: Colors.white,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Name and Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: languageProvider.isRTL 
                        ? CrossAxisAlignment.end 
                        : CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: languageProvider.textDirection,
                        child: Text(
                          member['name'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            fontFamily: 'Inter',
                            letterSpacing: 0.3,
                          ),
                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Directionality(
                        textDirection: languageProvider.textDirection,
                        child: Text(
                          member['title'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: memberColor,
                            fontFamily: 'Inter',
                          ),
                          textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      

                    ],
                  ),
                ),
              ],
            ),
          ),
          

          
          // Achievements Tags (only show if there are achievements)
          if (achievements.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: languageProvider.isRTL ? WrapAlignment.end : WrapAlignment.start,
                children: achievements.map((achievement) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: memberColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: memberColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Directionality(
                    textDirection: languageProvider.textDirection,
                    child: Text(
                      achievement,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: memberColor.withOpacity(0.9),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildCEOCard({
    required String name,
    required String role,
    required String description,
    required Color color,
    required Map<String, String> socialMedia,
    required ThemeProvider themeProvider,
    required LanguageProvider languageProvider,
    String? imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? Colors.grey[800] 
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: imagePath == null ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ) : null,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: imagePath != null
                    ? ClipOval(
                        child: Image.asset(
                          imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    color,
                                    color.withOpacity(0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: languageProvider.isRTL 
                      ? CrossAxisAlignment.end 
                      : CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: languageProvider.textDirection,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'Inter',
                        ),
                        textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Directionality(
                      textDirection: languageProvider.textDirection,
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                          fontFamily: 'Inter',
                        ),
                        textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    Directionality(
                      textDirection: languageProvider.textDirection,
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode 
                              ? Colors.white.withOpacity(0.7) 
                              : Colors.grey[600],
                          fontFamily: 'Inter',
                        ),
                        textAlign: languageProvider.isRTL ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Social Media Links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: socialMedia.entries.map((entry) {
              return _buildSocialMediaButton(
                entry.key,
                entry.value,
                color,
                themeProvider,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaButton(
    String platform,
    String url,
    Color color,
    ThemeProvider themeProvider,
  ) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildSocialMediaIcon(platform, color),
      ),
    );
  }

  Widget _buildSocialMediaIcon(String platform, Color color) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icon(
          Icons.facebook,
          size: 20,
          color: color,
        );
      case 'viber':
        return Image.asset(
          'assets/icon/viber.png',
          width: 20,
          height: 20,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.chat_bubble,
              size: 20,
              color: color,
            );
          },
        );
      default:
        return Icon(
          Icons.link,
          size: 20,
          color: color,
        );
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for Facebook
        if (url.contains('facebook.com')) {
          final Uri fallbackUri = Uri.parse(url);
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      // Handle any errors silently or show a message
      print('Could not launch $url: $e');
    }
  }
}
