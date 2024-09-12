import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7F5AF0);
  static const Color secondaryColor = Color(0xFF44475A);

  static ThemeData _baseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: MaterialColor(primaryColor.value, {
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor,
          600: primaryColor.withOpacity(0.7),
          700: primaryColor.withOpacity(0.8),
          800: primaryColor.withOpacity(0.9),
          900: primaryColor.withOpacity(1),
        }),
        brightness: brightness,
      ).copyWith(
        secondary: secondaryColor,
        surface: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        background: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F4F8),
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F4F8),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF302D41) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF2C2F3E) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF44475A) : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? secondaryColor : Colors.grey[800],
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get lightTheme => _baseTheme(Brightness.light);
  static ThemeData get darkTheme => _baseTheme(Brightness.dark);

  // Custom text styles
  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get headlineSmall => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );
  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  // Custom colors
  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.background;
  static Color primaryColorLight(BuildContext context) =>
      Theme.of(context).colorScheme.primary.withOpacity(0.1);

  // Custom methods for consistent styling
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: surfaceColor(context),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static EdgeInsets get defaultPadding => const EdgeInsets.all(16);
}
