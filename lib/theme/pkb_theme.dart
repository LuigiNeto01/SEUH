import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Define a identidade visual do aplicativo Seuh.
///
/// Centraliza todas as cores, gradientes, estilos de texto e decorações
/// reutilizadas ao longo das telas e widgets.
class PkbTheme {
  // ── Gradiente de fundo ────────────────────────────────────────────────────

  /// Gradiente azul-celeste que cobre o fundo de todas as telas.
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8FCDF5), Color(0xFFBFE6FF), Color(0xFFE6F5FF)],
    stops: [0.0, 0.52, 1.0],
  );

  // ── Paleta de cores ───────────────────────────────────────────────────────

  /// Superfície de card com leve transparência.
  static const Color surface = Color(0xDBFFFFFF);

  /// Superfície secundária com mais transparência (ex: chips desativados).
  static const Color surface2 = Color(0x80FFFFFF);

  /// Cor primária do app — azul escuro, usada em botões e destaques.
  static const Color primary = Color(0xFF2E72A0);

  /// Cor de acento — azul mais vivo, usado em rótulos de destaque.
  static const Color accent = Color(0xFF3F9BD8);

  /// Cor principal do texto sobre fundos claros.
  static const Color textColor = Color(0xFF173C54);

  /// Cor de texto secundário e placeholders.
  static const Color muted = Color(0xFF5C82A0);

  /// Cor de bordas e divisores com transparência.
  static const Color line = Color(0x99FFFFFF);

  /// Cor do primeiro segmento da roda (tom azul médio).
  static const Color seg1 = Color(0xFF2d72ab);

  /// Cor do segundo segmento da roda (azul-marinho escuro).
  static const Color seg2 = Color(0xFF1e3f52);

  /// Cor dourada usada no ícone de streak e na bússola norte.
  static const Color gold = Color(0xFFEFC06A);

  // ── Layout ────────────────────────────────────────────────────────────────

  /// Raio padrão dos cantos dos cards.
  static const double cardRadius = 26.0;

  // ── Tipografia ────────────────────────────────────────────────────────────

  /// Tema de texto com Quicksand (títulos) e Nunito (corpo).
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displaySmall: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineLarge: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineSmall: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: GoogleFonts.nunito(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleSmall: GoogleFonts.nunito(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.nunito(color: textColor),
        bodyMedium: GoogleFonts.nunito(color: textColor),
        bodySmall: GoogleFonts.nunito(color: muted),
        labelLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        labelMedium: GoogleFonts.nunito(color: muted),
        labelSmall: GoogleFonts.nunito(color: muted),
      );

  /// ThemeData completo do aplicativo, aplicado no MaterialApp.
  static ThemeData get theme => ThemeData(
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        textTheme: textTheme,
        scaffoldBackgroundColor: Colors.transparent,
        cardTheme: CardThemeData(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          elevation: 0,
        ),
      );

  // ── Decorações reutilizáveis ──────────────────────────────────────────────

  /// Decoração de card padrão com sombra suave.
  static BoxDecoration cardDecoration({double? radius}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius ?? cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Decoração de superfície secundária, sem sombra.
  static BoxDecoration surface2Decoration({double? radius}) => BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(radius ?? cardRadius),
      );
}
