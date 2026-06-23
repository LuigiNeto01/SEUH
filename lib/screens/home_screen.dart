import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme/pkb_theme.dart';
import '../widgets/compass_wheel.dart';
import '../widgets/floating_clouds.dart';
import '../widgets/category_chip.dart';
import '../services/spin_audio.dart';

/// Tela inicial do Seuh, com a roda de roleta e o resultado da penitência do dia.
///
/// Responsável por:
/// - Animar a roda de bússola ao revelar a penitência.
/// - Disparar som de vento e vibração durante o spin.
/// - Exibir a penitência revelada com countdown para o próximo dia.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  /// Rotação atual exibida na roda (em graus), sincronizada com a animação.
  double _displayRotation = 0.0;

  Timer? _countdownTimer;
  Timer? _vibrationTimer;

  /// Texto do contador regressivo até a meia-noite (ex: "5h 32min").
  String _countdown = '';

  final SpinAudio _audio = SpinAudio();

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    // Restaura a posição da roda salva na sessão anterior após o build inicial.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<AppState>();
        if (state.rotation != 0) {
          setState(() => _displayRotation = state.rotation);
        }
      }
    });

    // Animação com curva de desaceleração suave, simulando uma roleta física.
    _spinAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: const Cubic(0.16, 0.78, 0.28, 1.0),
      ),
    );

    _spinAnimation.addListener(() {
      setState(() {
        _displayRotation = _spinAnimation.value;
      });
    });

    // Inicia o countdown e o atualiza a cada segundo.
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _countdownTimer?.cancel();
    _vibrationTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }

  /// Atualiza o texto do countdown com o tempo restante até a meia-noite.
  void _updateCountdown() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    setState(() {
      _countdown = '${h}h ${m.toString().padLeft(2, '0')}min';
    });
  }

  /// Retorna a saudação de acordo com o horário atual.
  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    String time;
    if (hour < 12) {
      time = 'Bom dia';
    } else if (hour < 18) {
      time = 'Boa tarde';
    } else {
      time = 'Boa noite';
    }
    if (name != null && name.isNotEmpty) {
      return '$time, $name!';
    }
    return '$time!';
  }

  /// Inicia a animação de spin, o áudio de vento e a vibração periódica.
  ///
  /// Bloqueia novo spin se já estiver em andamento ou se o resultado já foi revelado.
  void _spin() async {
    final state = context.read<AppState>();
    if (state.spinning || state.revealed) return;

    final (targetRot, chosenId) = state.prepareSpinResult();
    state.startSpin();

    // Inicia som de vento e vibração imediatamente ao pressionar o botão.
    _audio.play(7.0);
    HapticFeedback.mediumImpact();
    _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      HapticFeedback.mediumImpact();
    });

    // Recria a animação com o novo destino de rotação.
    _spinAnimation = Tween<double>(
      begin: _displayRotation,
      end: targetRot,
    ).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: const Cubic(0.16, 0.78, 0.28, 1.0),
      ),
    );

    _spinAnimation.addListener(() {
      setState(() {
        _displayRotation = _spinAnimation.value;
      });
    });

    _spinController.reset();
    await _spinController.forward();

    _vibrationTimer?.cancel();
    _vibrationTimer = null;

    if (mounted) {
      // Vibração mais intensa ao parar, sinalizando o resultado.
      HapticFeedback.heavyImpact();
      state.finishSpin(targetRot, chosenId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com nome do app e pill de streak.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seuh',
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: PkbTheme.textColor,
                ),
              ),
              _StreakPill(streak: state.streak),
            ],
          ),
          const SizedBox(height: 16),

          // Saudação personalizada pelo nome e horário.
          Text(
            _greeting(state.userName),
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: PkbTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sua penitência do dia aguarda.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: PkbTheme.muted,
            ),
          ),
          const SizedBox(height: 24),

          // Roda de bússola animada.
          Center(
            child: CompassWheel(
              rotationDegrees: _displayRotation,
              size: 300,
            ),
          ),
          const SizedBox(height: 28),

          // Área de ação: botão de revelar ou card de resultado.
          if (!state.revealed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.spinning ? null : _spin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PkbTheme.primary,
                  disabledBackgroundColor: PkbTheme.primary.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  state.spinning ? 'Revelando...' : 'Revelar penitência',
                  style: GoogleFonts.quicksand(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${state.remaining} desafios restantes neste ciclo',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: PkbTheme.muted,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Aviso espiritual exibido antes da revelação.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Não faça penitências que prejudiquem sua saúde ou por vã glória. Faça-as por amor a Deus, não apenas para cumprir tarefas vazias.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: PkbTheme.muted.withOpacity(0.7),
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else if (state.resultPenance != null) ...[
            _RevealedCard(state: state, countdown: _countdown),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Pill compacto exibido no canto superior direito com o número de dias em sequência.
class _StreakPill extends StatelessWidget {
  final int streak;
  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: PkbTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_sunny_rounded, size: 18, color: Color(0xFFEFC06A)),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PkbTheme.textColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'dias',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: PkbTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card exibido após a revelação da penitência do dia.
///
/// Mostra nome, tags, dificuldade, descrição e countdown até a próxima revelação.
class _RevealedCard extends StatelessWidget {
  final AppState state;
  final String countdown;

  const _RevealedCard({required this.state, required this.countdown});

  @override
  Widget build(BuildContext context) {
    final p = state.resultPenance!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: PkbTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PENITÊNCIA DE HOJE',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: PkbTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.name,
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: PkbTheme.textColor,
                ),
              ),
              const SizedBox(height: 10),

              // Tags e indicador de dificuldade lado a lado.
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ...p.tags.map((tag) => CatBadge(cat: tag)),
                  DifficultyChip(diff: p.diff),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                p.desc,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: PkbTheme.muted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Indicador de bloqueio até amanhã.
        Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 15, color: PkbTheme.muted),
            const SizedBox(width: 6),
            Text(
              'Disponível novamente amanhã',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: PkbTheme.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 21),
          child: Text(
            'Libera em $countdown',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: PkbTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Aviso espiritual repetido após a revelação.
        Text(
          'Não faça penitências que prejudiquem sua saúde ou por vã glória. Faça-as por amor a Deus, não apenas para cumprir tarefas vazias.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: PkbTheme.muted.withOpacity(0.7),
            height: 1.6,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
