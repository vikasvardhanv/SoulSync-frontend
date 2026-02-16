import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SoulSyncColors {
  // Primary palette — matches CSS variables in index.css
  static const Color warmCream = Color(0xFFFEFCF7);
  static const Color softCoral = Color(0xFFFF9A8B);
  static const Color warmPeach = Color(0xFFFFB3BA);
  static const Color gentleMint = Color(0xFFA8E6CF);
  static const Color softLavender = Color(0xFFD4A5FF);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color gentleSage = Color(0xFFB8D4A8);
  static const Color softSky = Color(0xFFA8D8FF);
  static const Color warmGold = Color(0xFFFFD93D);
  static const Color gentleRose = Color(0xFFFFB3D9);

  // Text / neutrals
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color warm600 = Color(0xFF6B7280);
  static const Color warm700 = Color(0xFF4B5563);
  static const Color warm800 = Color(0xFF1F2937);

  // Coral shades
  static const Color coral50 = Color(0xFFFFF5F3);
  static const Color coral100 = Color(0xFFFFE6E1);
  static const Color coral200 = Color(0xFFFFCFC7);
  static const Color coral400 = Color(0xFFFF9A8B);
  static const Color coral500 = Color(0xFFFF7B6B);
  static const Color coral600 = Color(0xFFE8695A);
  static const Color coral700 = Color(0xFFCC5744);

  // Peach shades
  static const Color peach200 = Color(0xFFFFD9D9);
  static const Color peach400 = Color(0xFFFFB3BA);
  static const Color peach500 = Color(0xFFFFA0AA);

  // Mint shades
  static const Color mint200 = Color(0xFFCCF5E1);
  static const Color mint400 = Color(0xFFA8E6CF);
  static const Color mint500 = Color(0xFF8CDBB5);

  // Gradients
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warmCream, warmBeige],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softCoral, warmPeach],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gentleMint, gentleSage],
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [coral500, peach500],
  );
}

class SoulSyncTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SoulSyncColors.warmCream,
      colorScheme: ColorScheme.light(
        primary: SoulSyncColors.softCoral,
        onPrimary: Colors.white,
        secondary: SoulSyncColors.gentleMint,
        onSecondary: SoulSyncColors.textPrimary,
        surface: Colors.white,
        onSurface: SoulSyncColors.textPrimary,
        error: const Color(0xFFEF4444),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.quicksand(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: SoulSyncColors.textPrimary,
        ),
        displayMedium: GoogleFonts.quicksand(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: SoulSyncColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.quicksand(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: SoulSyncColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: SoulSyncColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SoulSyncColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: SoulSyncColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: SoulSyncColors.textSecondary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: SoulSyncColors.textSecondary,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: SoulSyncColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SoulSyncColors.softCoral,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          shadowColor: SoulSyncColors.softCoral.withValues(alpha: 0.3),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SoulSyncColors.softCoral.withValues(alpha: 0.2), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SoulSyncColors.softCoral.withValues(alpha: 0.2), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SoulSyncColors.softCoral, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          color: SoulSyncColors.textMuted,
          fontSize: 15,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.8),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SoulSyncColors.warm800,
        ),
        iconTheme: const IconThemeData(color: SoulSyncColors.warm800),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: SoulSyncColors.coral500,
        unselectedItemColor: SoulSyncColors.warm600,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
    );
  }
}
