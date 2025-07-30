import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Quiz data
  final int userPoints = 2450;
  final String userRank = '15 لە 1250';
  
  // Leaderboard data
  final List<Map<String, dynamic>> leaderboardData = [
    {'name': 'د. ئەحمەد محەمەد', 'points': 3250, 'rank': 1},
    {'name': 'د. فاتمە عەلی', 'points': 2980, 'rank': 2},
    {'name': 'د. عومەر حەسەن', 'points': 2750, 'rank': 3},
    {'name': 'Shadman Othman', 'points': 2450, 'rank': 4, 'isCurrentUser': true},
    {'name': 'د. زێنەب کەریم', 'points': 2200, 'rank': 5},
  ];
  
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('گالەری'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('کامێرا'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هەڵەیەک ڕووی دا: $e')),
      );
    }
  }

  void _showLeaderboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Directionality(
                textDirection: Provider.of<LanguageProvider>(context).textDirection,
                child: const Text(
                  'پلەبەندی',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NRT',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            // Leaderboard list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: leaderboardData.length,
                itemBuilder: (context, index) {
                  final user = leaderboardData[index];
                  final isCurrentUser = user['isCurrentUser'] ?? false;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isCurrentUser 
                          ? Provider.of<ThemeProvider>(context).theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrentUser 
                          ? Border.all(color: Provider.of<ThemeProvider>(context).theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _getRankColor(user['rank']),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${user['rank']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade300,
                          child: Text(
                            user['name'].toString().substring(0, 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // Name
                        Expanded(
                          child: Directionality(
                            textDirection: user['name'].toString().contains('د.') 
                                ? TextDirection.rtl 
                                : TextDirection.ltr,
                            child: Text(
                              user['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isCurrentUser 
                                    ? FontWeight.bold 
                                    : FontWeight.w500,
                                fontFamily: user['name'].toString().contains('د.') 
                                    ? 'NRT' 
                                    : null,
                                color: isCurrentUser 
                                    ? const Color(0xFF4CAF50)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        
                        // Points
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user['points']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF4CAF50); // Green
    }
  }

  void _showLogoutDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Directionality(
            textDirection: languageProvider.textDirection,
            child: const Text(
              'چوونەدەرەوە',
              style: TextStyle(
                fontFamily: 'NRT',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Directionality(
            textDirection: languageProvider.textDirection,
            child: const Text(
              'دڵنیایت لە چوونەدەرەوە؟',
              style: TextStyle(
                fontFamily: 'NRT',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Directionality(
                textDirection: languageProvider.textDirection,
                child: const Text(
                  'پاشگەزبوونەوە',
                  style: TextStyle(
                    fontFamily: 'NRT',
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: Directionality(
                textDirection: languageProvider.textDirection,
                child: const Text(
                  'چوونەدەرەوە',
                  style: TextStyle(
                    fontFamily: 'NRT',
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: AlertDialog(
            title: const Text(
              'سڕینەوەی هەژمار',
              style: TextStyle(
                fontFamily: 'NRT',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            content: const Text(
              'ئایا دڵنیایت لە سڕینەوەی هەژمارەکەت؟ ئەم کردارە ناگەڕێتەوە و هەموو زانیارییەکانت دەسڕێتەوە.',
              style: TextStyle(
                fontFamily: 'NRT',
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'هەڵوەشاندنەوە',
                  style: TextStyle(
                    fontFamily: 'NRT',
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performDeleteAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'سڕینەوە',
                  style: TextStyle(
                    fontFamily: 'NRT',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: Provider.of<LanguageProvider>(context, listen: false).textDirection,
              child: const Text(
                'بە سەرکەوتوویی چوویتە دەرەوە',
                style: TextStyle(
                  fontFamily: 'NRT',
                ),
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: Provider.of<LanguageProvider>(context, listen: false).textDirection,
              child: Text(
                'هەڵەیەک ڕووی دا: $e',
                style: const TextStyle(
                  fontFamily: 'NRT',
                ),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performDeleteAccount() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Directionality(
            textDirection: languageProvider.textDirection,
            child: const AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text(
                    'سڕینەوەی هەژمار...',
                    style: TextStyle(
                      fontFamily: 'NRT',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      
      final result = await authProvider.deleteAccount();
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: languageProvider.textDirection,
              child: Text(
                result['message'] ?? 'هەڵەیەک ڕووی دا',
                style: const TextStyle(
                  fontFamily: 'NRT',
                ),
              ),
            ),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
      
      // If deletion was successful, the user will be automatically signed out
      // and the AuthProvider will handle the state change
      
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: Provider.of<LanguageProvider>(context, listen: false).textDirection,
              child: Text(
                'هەڵەیەک ڕووی دا: $e',
                style: const TextStyle(
                  fontFamily: 'NRT',
                ),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Show login page if user is not authenticated
    if (!authProvider.isSignedIn) {
      return const LoginPage();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Directionality(
          textDirection: languageProvider.textDirection,
          child: Text(
            'پرۆفایل',
            style: TextStyle(
              fontFamily: 'NRT',
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
            tooltip: 'چوونەدەرەوە',
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (_profileImage != null
                                ? FileImage(_profileImage!)
                                : authProvider.userPhotoUrl != null
                                    ? NetworkImage(authProvider.userPhotoUrl!)
                                    : null) as ImageProvider<Object>?,
                        child: _profileImage == null && authProvider.userPhotoUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // User Name
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      authProvider.userDisplayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quiz Info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    decoration: BoxDecoration(
                      color: themeProvider.theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Points Section
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.stars,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$userPoints',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: languageProvider.textDirection,
                                child: const Text(
                                  'خاڵ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontFamily: 'NRT',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Divider
                        Container(
                          height: 60,
                          width: 1,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        
                        // Rank Section
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: themeProvider.theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.leaderboard,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '#15',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: languageProvider.textDirection,
                                child: const Text(
                                  'پلەبەندی',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontFamily: 'NRT',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'ئاگادارکردنەوەکان',
                    languageProvider: languageProvider,
                    onTap: () {
                      // Handle notifications
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.leaderboard_outlined,
                    title: 'پلەبەندی',
                    languageProvider: languageProvider,
                    onTap: () {
                      _showLeaderboard();
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'چوونەدەرەوە',
                    color: const Color(0xFFFF5722),
                    languageProvider: languageProvider,
                    onTap: () {
                      _showLogoutDialog();
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.delete_outline,
                    title: 'سڕینەوەی هەژمار',
                    color: const Color(0xFFFF5722),
                    languageProvider: languageProvider,
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required LanguageProvider languageProvider,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.grey.shade600,
        size: 24,
      ),
      title: Directionality(
        textDirection: languageProvider.textDirection,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'NRT',
            color: color ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      trailing: Icon(
        languageProvider.isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
        color: Colors.grey.shade400,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade200,
      indent: 60,
      endIndent: 20,
    );
  }
}
