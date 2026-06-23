import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme/pkb_theme.dart';
import '../widgets/progress_ring.dart';

/// Tela de progresso do usuário.
///
/// Exibe três cards:
/// - Progresso do ciclo atual com anel visual.
/// - Sequência de dias consecutivos (streak).
/// - Histórico das últimas penitências concluídas.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu progresso',
            style: GoogleFonts.quicksand(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: PkbTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Um ciclo de cada vez.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: PkbTheme.muted,
            ),
          ),
          const SizedBox(height: 24),

          // Card do ciclo atual com anel de progresso.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: PkbTheme.cardDecoration(),
            child: Row(
              children: [
                ProgressRing(
                  completed: state.completedThisCycle,
                  total: state.cycleTotal,
                  size: 140,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CICLO ATUAL',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: PkbTheme.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'desafios concluídos',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: PkbTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Faltam ${state.cycleTotal - state.completedThisCycle} para reiniciar o ciclo.',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: PkbTheme.muted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card da sequência de dias consecutivos.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: PkbTheme.cardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEQUÊNCIA ATUAL',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: PkbTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${state.streak} dias seguidos',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: PkbTheme.textColor,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.wb_sunny_rounded,
                  size: 48,
                  color: Color(0xFFEFC06A),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card do histórico de penitências concluídas.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: PkbTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÚLTIMAS PENITÊNCIAS',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: PkbTheme.muted,
                  ),
                ),
                const SizedBox(height: 14),
                ...state.history.map((item) => _HistoryItem(item: item)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Item de linha no histórico de penitências.
class _HistoryItem extends StatelessWidget {
  final HistoryItem item;
  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Indicador visual de bullet.
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: PkbTheme.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  item.when,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: PkbTheme.muted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PkbTheme.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
