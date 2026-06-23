import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/pkb_theme.dart';

/// Anel de progresso circular exibido na tela de progresso.
///
/// Mostra visualmente quantas penitências do ciclo já foram concluídas,
/// com o contador numérico "concluídas/total" ao centro.
class ProgressRing extends StatelessWidget {
  /// Quantidade de penitências concluídas no ciclo atual.
  final int completed;

  /// Total de penitências no ciclo.
  final int total;

  /// Tamanho do widget em pixels lógicos.
  final double size;

  const ProgressRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              // Evita divisão por zero quando o ciclo ainda não foi carregado.
              progress: total > 0 ? completed / total : 0,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$completed/$total',
                style: GoogleFonts.quicksand(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.bold,
                  color: PkbTheme.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Painter responsável por desenhar o anel de progresso via Canvas.
class _RingPainter extends CustomPainter {
  /// Progresso de 0.0 a 1.0.
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    // Trilha de fundo: círculo completo com cor discreta.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = PkbTheme.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Arco de progresso: desenhado no sentido horário a partir do topo (−π/2).
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,            // inicia no topo
        2 * pi * progress,  // varre proporcionalmente ao progresso
        false,
        Paint()
          ..color = PkbTheme.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
