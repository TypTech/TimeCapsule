import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum für verschiedene Theme-Varianten
enum AppThemeType { standard, ocean, forest, sunset, minimal, elegant }

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppThemeType _themeType = AppThemeType.standard;
  bool _initialized = false;

  // Primary app colors - Modernere Farben
  static const Color _primaryLight = Color(0xFF6A5AE0); // Modernes Lila
  static const Color _primaryDark = Color(
    0xFF8270FF,
  ); // Helleres Lila für Dunkel-Modus

  // Accent colors
  static const Color _accentLight = Color(0xFFFF8B93); // Sanftes Korallen-Rot
  static const Color _accentDark = Color(
    0xFFFF9FB5,
  ); // Helleres Rosa für Dunkel-Modus

  // Background colors
  static const Color _backgroundLight = Color(0xFFF9F9FE); // Sehr helles Lila
  static const Color _backgroundDark = Color(0xFF15151F); // Tiefes Dunkelblau

  // Card/Surface colors
  static const Color _surfaceLight = Colors.white;
  static const Color _surfaceDark = Color(
    0xFF1E1E2E,
  ); // Dunkleres Blau für Karten

  // Theme type Farben
  // Ocean Theme
  static const Color _oceanPrimary = Color(0xFF4A90E2); // Helles Blau
  static const Color _oceanAccent = Color(0xFF7ABFFF); // Sehr helles Blau
  static const Color _oceanSurface = Color(
    0xFFECF4FF,
  ); // Kaum merkliches Hellblau
  static const Color _oceanDarkPrimary = Color(0xFF2979FF); // Leuchtendes Blau
  static const Color _oceanDarkSurface = Color(0xFF0A192F); // Tiefes Navy Blau

  // Forest Theme
  static const Color _forestPrimary = Color(0xFF43A047); // Frisches Grün
  static const Color _forestAccent = Color(0xFF66BB6A); // Helles Grün
  static const Color _forestSurface = Color(
    0xFFEDF7ED,
  ); // Kaum merkliches Hellgrün
  static const Color _forestDarkPrimary = Color(0xFF2E7D32); // Tieferes Grün
  static const Color _forestDarkSurface = Color(
    0xFF0D1F12,
  ); // Sehr dunkles Grün

  // Sunset Theme
  static const Color _sunsetPrimary = Color(0xFFFF9800); // Orange
  static const Color _sunsetAccent = Color(0xFFFFB74D); // Helles Orange
  static const Color _sunsetSurface = Color(0xFFFFF8E1); // Sehr helles Gelb
  static const Color _sunsetDarkPrimary = Color(
    0xFFFF9100,
  ); // Leuchtendes Orange
  static const Color _sunsetDarkSurface = Color(0xFF2D1706); // Dunkelbraun

  // Minimal Theme
  static const Color _minimalPrimary = Color(0xFF212121); // Fast-Schwarz
  static const Color _minimalAccent = Color(0xFF9E9E9E); // Grau
  static const Color _minimalSurface = Color(0xFFF5F5F5); // Fast-Weiß
  static const Color _minimalDarkPrimary = Color(0xFFE0E0E0); // Hellgrau
  static const Color _minimalDarkSurface = Color(
    0xFF121212,
  ); // Material Dark Hintergrund

  // Elegant Theme
  static const Color _elegantPrimary = Color(0xFF7B1FA2); // Tiefes Violett
  static const Color _elegantAccent = Color(0xFFBA68C8); // Helles Lila
  static const Color _elegantSurface = Color(0xFFF3E5F5); // Sehr helles Lila
  static const Color _elegantDarkPrimary = Color(0xFFAB47BC); // Helles Violett
  static const Color _elegantDarkSurface = Color(
    0xFF1A0A22,
  ); // Sehr dunkles Violett

  // Constructor
  ThemeService() {
    _loadPreferences();
  }

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
        tertiary: _accentLight,
        background: _backgroundLight,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor:
            _themeType == AppThemeType.standard
                ? _backgroundLight // Für Standard-Theme: transparente AppBar
                : primaryColor, // Für andere Themes: farbige AppBar
        foregroundColor:
            _themeType == AppThemeType.standard
                ? Color(0xFF0A0A26) // Dunkler Text für helle AppBar
                : Colors.white, // Weißer Text für farbige AppBar
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color:
              _themeType == AppThemeType.standard
                  ? Color(0xFF0A0A26) // Dunkler Text für helle AppBar
                  : Colors.white, // Weißer Text für farbige AppBar
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: Color(0xFF0A0A26),
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF0A0A26),
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Color(0xFF0A0A26)),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF0A0A26)),
      ),
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFFA0A0A0),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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
        tertiary: _accentDark,
        background: _backgroundDark,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor:
            _backgroundDark, // Dunkle AppBar für alle Themes im Dark Mode
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
        shadowColor: Colors.black.withOpacity(0.3),
        color: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
      ),
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFFA0A0A0),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Vereinfachte toggleTheme-Methode für minimale Funktionalität
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      final themeTypeIndex = prefs.getInt('themeType') ?? 0;

      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _themeType = AppThemeType.values[themeTypeIndex];
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setInt('themeType', _themeType.index);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setThemeType(AppThemeType type) async {
    _themeType = type;
    await _savePreferences();
    notifyListeners();
  }
}
