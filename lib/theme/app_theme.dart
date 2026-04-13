import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFF1A2235);
  static const Color card = Color(0xFF1E2B3C);
  static const Color cardHighlight = Color(0xFF243347);

  static const Color primary = Color(0xFF3A7BFF);
  static const Color primaryLight = Color(0xFF6B9FFF);
  static const Color accent = Color(0xFF00D4AA);

  static const Color gain = Color(0xFF00C896);
  static const Color gainLight = Color(0xFF00E8AD);
  static const Color loss = Color(0xFFFF4D6A);
  static const Color lossLight = Color(0xFFFF7088);

  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8B9CC0);
  static const Color textTertiary = Color(0xFF4A5A78);

  static const Color divider = Color(0xFF1E2B3C);
  static const Color border = Color(0xFF243040);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3A7BFF), Color(0xFF1A4FCC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gainGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF009E75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lossGradient = LinearGradient(
    colors: [Color(0xFFFF4D6A), Color(0xFFCC2244)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF0E1628)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: GoogleFonts.inter(color: textSecondary),
        bodySmall: GoogleFonts.inter(color: textTertiary),
        labelLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.inter(color: textSecondary),
        labelSmall: GoogleFonts.inter(color: textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textTertiary,
        indicatorColor: primary,
        dividerColor: divider,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
