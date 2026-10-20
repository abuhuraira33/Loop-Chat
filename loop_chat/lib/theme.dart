import 'package:flutter/material.dart';

enum AppThemeColor {
  teal('Teal', Color(0xFF147D70)),
  indigo('Indigo', Color(0xFF3F51B5)),
  rose('Rose', Color(0xFFE91E63)),
  amber('Amber', Color(0xFFD97706)),
  emerald('Emerald', Color(0xFF16A34A));

  const AppThemeColor(this.label, this.color);
  final String label;
  final Color color;
}

abstract final class LoopTheme {
  static const ink = Color(0xFF173C37);

  static ThemeData light([AppThemeColor accent = AppThemeColor.teal]) =>
      _build(Brightness.light, accent);

  static ThemeData dark([AppThemeColor accent = AppThemeColor.teal]) =>
      _build(Brightness.dark, accent);

  static ThemeData _build(Brightness brightness, AppThemeColor accent) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent.color,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF111E1C)
          : const Color(0xFFF7F9F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF20312E) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: isDark ? const Color(0xFFECF4F0) : ink,
        displayColor: isDark ? const Color(0xFFECF4F0) : ink,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: .45),
        space: 1,
      ),
    );
  }
}
