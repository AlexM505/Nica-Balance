import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // Paleta de Colores Dark Premium
  // static const primaryColor = Color(0xFF3B82F6);       // Azul Eléctrico Vibrante
  static const accentColor = Color(0xFF45B649);        // Esmeralda Moderno
  // static const backgroundColor = Color(0xFF0B1120);    // Azul Pizarra Muy Oscuro (Fondo)
  // static const surfaceColor = Color(0xFF1E293B);       // Gris Azulado Oscuro (Tarjetas/Inputs)
  static const textPrimary = Color(0xFFF8FAFC);        // Blanco Hueso Alta Claridad
  static const textSecondary = Color(0xFF94A3B8);      // Gris Atramado (Subtítulos)
  static const borderColor = Color(0xFF334155);        // Borde Sutil Oscuro
  
  // static const backgroundColor = Color(0xFF0C1324); 

  static const primaryColor = Color(0xFF2D8CFF); 
  static const backgroundColor = Color(0xFF07111F); 
  static const surfaceColor = Color(0xFF101C2F); 

  static ThemeData get premiumDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      // fontFamily: 'Montserrat',

      // Typography
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(
            color: textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: const TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: const TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),

      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary, size: 22),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  // --- TEMA CLARO ---
  static const Color backgroundLight = Color(0xFFEEF0F1);
  static const Color surfaceLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryColor,
      fontFamily: 'Poppins',

      // Typography
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(
            color: textPrimaryLight,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: const TextStyle(
            color: textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(
            color: textPrimaryLight,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: const TextStyle(
            color: textSecondaryLight,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimaryLight),
        titleTextStyle: TextStyle(color: textPrimaryLight, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceLight,
        background: backgroundLight,
      ),
    );
  }

  // Helpers estáticos dinámicos para mantener limpio tu código antiguo independiente
  // Nota: Si usabas AppTheme.surfaceColor de forma estática en tus contenedores,
  // puedes hacer que lean el contexto de esta forma o usar Theme.of(context).colorScheme.surface
  static Color getBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundColor : backgroundLight;

  static Color getSurfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceColor : surfaceLight;

  static Color getBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderColor : borderLight;

  static Color getTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimary : textPrimaryLight;

  static Color getTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondary : textSecondaryLight;
}