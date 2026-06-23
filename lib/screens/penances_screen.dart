import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme/pkb_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/penance_card.dart';

/// Tela de listagem de todas as penitências do ciclo.
///
/// Permite filtrar por categoria/tag via chips horizontais e
/// indica visualmente quais penitências já foram sorteadas no ciclo atual.
class PenancesScreen extends StatelessWidget {
  const PenancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = state.allCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho com título e total do ciclo.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Penitências',
                style: GoogleFonts.quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: PkbTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ciclo · ${state.cycleTotal} desafios',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: PkbTheme.muted,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Scroll horizontal de chips para filtrar por categoria.
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              return CategoryChip(
                label: cat,
                isActive: state.activeCat == cat,
                onTap: () => state.setActiveCat(cat),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Lista de penitências filtradas pela categoria ativa.
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.filteredPenances.length,
            itemBuilder: (context, i) {
              final p = state.filteredPenances[i];
              return PenanceCard(
                penance: p,
                isDrawn: state.isDrawn(p.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
