import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // Paleta de Colores Dark Premium
  static const primaryColor = Color(0xFF3B82F6);       // Azul Eléctrico Vibrante
  static const accentColor = Color(0xFF45B649);        // Esmeralda Moderno
  // static const backgroundColor = Color(0xFF0B1120);    // Azul Pizarra Muy Oscuro (Fondo)
  static const surfaceColor = Color(0xFF1E293B);       // Gris Azulado Oscuro (Tarjetas/Inputs)
  static const textPrimary = Color(0xFFF8FAFC);        // Blanco Hueso Alta Claridad
  static const textSecondary = Color(0xFF94A3B8);      // Gris Atramado (Subtítulos)
  static const borderColor = Color(0xFF334155);        // Borde Sutil Oscuro
  // static const backgroundColor = Color(0xFF061313); 
  static const backgroundColor = Color(0xFF0C1324); 

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
}