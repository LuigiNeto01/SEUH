import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme/pkb_theme.dart';
import '../widgets/floating_clouds.dart';
import '../widgets/name_modal.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'penances_screen.dart';

/// Tela principal do aplicativo, responsável pelo layout global.
///
/// Gerencia o fundo gradiente, as nuvens animadas, a troca de telas
/// e a barra de navegação inferior. Exibe o modal de nome na primeira
/// execução até o usuário se identificar.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final screens = [
      const HomeScreen(),
      const ProgressScreen(),
      const PenancesScreen(),
    ];

    // Aguarda o carregamento inicial antes de renderizar o conteúdo.
    if (!state.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Gradiente de fundo aplicado em toda a tela.
          Container(
            decoration: const BoxDecoration(
              gradient: PkbTheme.bgGradient,
            ),
          ),

          // Nuvens flutuantes exibidas apenas na tela inicial.
          if (state.currentScreen == 0)
            const Positioned.fill(
              child: FloatingClouds(),
            ),

          // Conteúdo da tela ativa, respeitando a área segura do dispositivo.
          SafeArea(
            child: screens[state.currentScreen],
          ),

          // Modal de boas-vindas sobreposto até o usuário informar o nome.
          if (state.showNameModal)
            const Positioned.fill(
              child: NameModal(),
            ),
        ],
      ),
      bottomNavigationBar: _PkbBottomNav(currentIndex: state.currentScreen),
    );
  }
}

/// Barra de navegação inferior personalizada com três itens de igual largura.
class _PkbBottomNav extends StatelessWidget {
  final int currentIndex;
  const _PkbBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Cada item ocupa 1/3 da largura via Expanded.
              Expanded(
                child: _NavItem(
                  icon: Icons.explore_rounded,
                  label: 'Início',
                  isActive: currentIndex == 0,
                  onTap: () => context.read<AppState>().setScreen(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Progresso',
                  isActive: currentIndex == 1,
                  onTap: () => context.read<AppState>().setScreen(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.list_alt_rounded,
                  label: 'Penitências',
                  isActive: currentIndex == 2,
                  onTap: () => context.read<AppState>().setScreen(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item individual da barra de navegação inferior.
///
/// Exibe ícone e rótulo, com animação de cor ao ativar/desativar.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? PkbTheme.primary : PkbTheme.muted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
