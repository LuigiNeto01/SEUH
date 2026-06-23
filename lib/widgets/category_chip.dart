import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/penances_data.dart';
import '../theme/pkb_theme.dart';

/// Chip de filtro de categoria exibido na barra horizontal da tela de penitências.
///
/// Quando ativo, destaca-se com a cor primária e uma sombra suave.
class CategoryChip extends StatelessWidget {
  /// Rótulo da categoria exibido no chip.
  final String label;

  /// Define se este chip está selecionado como filtro ativo.
  final bool isActive;

  /// Callback invocado ao tocar no chip.
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? PkbTheme.primary : PkbTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: PkbTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : PkbTheme.muted,
          ),
        ),
      ),
    );
  }
}

/// Badge compacto que exibe o nível de dificuldade de uma penitência.
///
/// A cor de fundo e do texto varia conforme o nível: verde (Leve), dourado (Média),
/// laranja-salmão (Intensa).
class DifficultyChip extends StatelessWidget {
  /// Nível de dificuldade (1 = Leve, 2 = Média, 3 = Intensa).
  final int diff;

  const DifficultyChip({super.key, required this.diff});

  @override
  Widget build(BuildContext context) {
    final color = diffColor(diff);
    final label = diffLabel(diff);

    // Fundo com leve tinta da cor da dificuldade, mesclada com branco.
    final bg = Color.alphaBlend(color.withOpacity(0.22), Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Badge de categoria/tag exibido nos cards de penitência.
///
/// A cor varia de acordo com o mapa [kCatColors] em penances_data.dart.
class CatBadge extends StatelessWidget {
  /// Nome da categoria/tag a ser exibida.
  final String cat;

  const CatBadge({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final color = catColor(cat);
    final bg = Color.alphaBlend(color.withOpacity(0.22), Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        cat,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
