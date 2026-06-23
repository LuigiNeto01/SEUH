import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/penance.dart';
import '../theme/pkb_theme.dart';
import 'category_chip.dart';

/// Card que exibe os detalhes de uma penitência na lista da tela de penitências.
///
/// Mostra nome, descrição, tags de categoria, dificuldade e
/// um badge indicando se a penitência já foi sorteada no ciclo atual.
class PenanceCard extends StatelessWidget {
  /// Penitência a ser exibida.
  final Penance penance;

  /// Indica se esta penitência já foi sorteada no ciclo atual.
  final bool isDrawn;

  const PenanceCard({
    super.key,
    required this.penance,
    this.isDrawn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: PkbTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  penance.name,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PkbTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge de status: "Sorteada" ou "Disponível".
              _StatusBadge(isDrawn: isDrawn),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            penance.desc,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: PkbTheme.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          // Tags e indicador de dificuldade lado a lado.
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...penance.tags.map((tag) => CatBadge(cat: tag)),
              DifficultyChip(diff: penance.diff),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge que indica se a penitência já foi sorteada no ciclo atual.
///
/// "Sorteada" em dourado quando já saiu; "Disponível" em azul quando ainda está no pool.
class _StatusBadge extends StatelessWidget {
  final bool isDrawn;
  const _StatusBadge({required this.isDrawn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDrawn
            ? const Color(0xFFEFC06A).withOpacity(0.18)
            : PkbTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isDrawn ? 'Sorteada' : 'Disponível',
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDrawn ? const Color(0xFFB8841A) : PkbTheme.primary,
        ),
      ),
    );
  }
}
