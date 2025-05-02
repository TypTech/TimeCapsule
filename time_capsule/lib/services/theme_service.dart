import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum für verschiedene Theme-Varianten
enum AppThemeType { standard, ocean, forest, sunset, minimal, elegant }

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppThemeType _themeType = AppThemeType.standard;

  // Primary app colors
  static const Color _primaryLight = Color(0xFF4A90E2);
  static const Color _primaryDark = Color(0xFF2979FF);

  // Accent colors
  static const Color _accentLight = Color(0xFFFF9800);
  static const Color _accentDark = Color(0xFFFFB74D);

  // Background colors
  static const Color _backgroundLight = Color(0xFFF5F5F5);
  static const Color _backgroundDark = Color(0xFF121212);

  // Card/Surface colors
  static const Color _surfaceLight = Colors.white;
  static const Color _surfaceDark = Color(0xFF1E1E1E);

  // Theme type Farben
  // Ocean Theme
  static const Color _oceanPrimary = Color(0xFF1A73E8);
  static const Color _oceanAccent = Color(0xFF00B0FF);
  static const Color _oceanSurface = Color(0xFFE3F2FD);
  static const Color _oceanDarkPrimary = Color(0xFF0D47A1);
  static const Color _oceanDarkSurface = Color(0xFF102A43);

  // Forest Theme
  static const Color _forestPrimary = Color(0xFF2E7D32);
  static const Color _forestAccent = Color(0xFF81C784);
  static const Color _forestSurface = Color(0xFFE8F5E9);
  static const Color _forestDarkPrimary = Color(0xFF1B5E20);
  static const Color _forestDarkSurface = Color(0xFF0D160B);

  // Sunset Theme
  static const Color _sunsetPrimary = Color(0xFFE64A19);
  static const Color _sunsetAccent = Color(0xFFFF9800);
  static const Color _sunsetSurface = Color(0xFFFFF3E0);
  static const Color _sunsetDarkPrimary = Color(0xFFBF360C);
  static const Color _sunsetDarkSurface = Color(0xFF1A0F00);

  // Minimal Theme
  static const Color _minimalPrimary = Color(0xFF212121);
  static const Color _minimalAccent = Color(0xFF757575);
  static const Color _minimalSurface = Color(0xFFFAFAFA);
  static const Color _minimalDarkPrimary = Color(0xFF9E9E9E);
  static const Color _minimalDarkSurface = Color(0xFF121212);

  // Elegant Theme
  static const Color _elegantPrimary = Color(0xFF6A1B9A);
  static const Color _elegantAccent = Color(0xFFAB47BC);
  static const Color _elegantSurface = Color(0xFFF3E5F5);
  static const Color _elegantDarkPrimary = Color(0xFF4A148C);
  static const Color _elegantDarkSurface = Color(0xFF170B21);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppThemeType get themeType => _themeType;

  // Getter für die Theme-Namen, die in der UI angezeigt werden
  String getThemeTypeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.standard:
        return 'Standard';
      case AppThemeType.ocean:
        return 'Ocean';
      case AppThemeType.forest:
        return 'Forest';
      case AppThemeType.sunset:
        return 'Sunset';
      case AppThemeType.minimal:
        return 'Minimal';
      case AppThemeType.elegant:
        return 'Elegant';
    }
  }

  // Aktuelle Primärfarbe basierend auf Theme-Typ und Modus
  Color get primaryColor {
    final isDark = _themeMode == ThemeMode.dark;

    switch (_themeType) {
      case AppThemeType.standard:
        return isDark ? _primaryDark : _primaryLight;
      case AppThemeType.ocean:
        return isDark ? _oceanDarkPrimary : _oceanPrimary;
      case AppThemeType.forest:
        return isDark ? _forestDarkPrimary : _forestPrimary;
      case AppThemeType.sunset:
        return isDark ? _sunsetDarkPrimary : _sunsetPrimary;
      case AppThemeType.minimal:
        return isDark ? _minimalDarkPrimary : _minimalPrimary;
      case AppThemeType.elegant:
        return isDark ? _elegantDarkPrimary : _elegantPrimary;
    }
  }

  // Aktuelle Akzentfarbe basierend auf Theme-Typ und Modus
  Color get accentColor {
    final isDark = _themeMode == ThemeMode.dark;

    switch (_themeType) {
      case AppThemeType.standard:
        return isDark ? _accentDark : _accentLight;
      case AppThemeType.ocean:
        return _oceanAccent;
      case AppThemeType.forest:
        return _forestAccent;
      case AppThemeType.sunset:
        return _sunsetAccent;
      case AppThemeType.minimal:
        return _minimalAccent;
      case AppThemeType.elegant:
        return _elegantAccent;
    }
  }

  // Surface-Farbe basierend auf Theme-Typ und Modus
  Color get surfaceColor {
    final isDark = _themeMode == ThemeMode.dark;

    switch (_themeType) {
      case AppThemeType.standard:
        return isDark ? _surfaceDark : _surfaceLight;
      case AppThemeType.ocean:
        return isDark ? _oceanDarkSurface : _oceanSurface;
      case AppThemeType.forest:
        return isDark ? _forestDarkSurface : _forestSurface;
      case AppThemeType.sunset:
        return isDark ? _sunsetDarkSurface : _sunsetSurface;
      case AppThemeType.minimal:
        return isDark ? _minimalDarkSurface : _minimalSurface;
      case AppThemeType.elegant:
        return isDark ? _elegantDarkSurface : _elegantSurface;
    }
  }

  // Create light theme
  ThemeData get lightTheme {
    final primaryColor = this.primaryColor;
    final accentColor = this.accentColor;
    final surfaceColor = this.surfaceColor;

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        background: _backgroundLight,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Create dark theme
  ThemeData get darkTheme {
    final primaryColor = this.primaryColor;
    final accentColor = this.accentColor;
    final surfaceColor = this.surfaceColor;

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: accentColor,
        background: _backgroundDark,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        color: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        fillColor: surfaceColor,
        filled: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final themeTypeIndex = prefs.getInt('themeType') ?? 0;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _themeType = AppThemeType.values[themeTypeIndex];

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  Future<void> setThemeType(AppThemeType type) async {
    _themeType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeType', type.index);
    notifyListeners();
  }
}
