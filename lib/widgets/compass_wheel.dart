import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/pkb_theme.dart';

class CompassWheel extends StatelessWidget {
  final double rotationDegrees;
  final double size;

  const CompassWheel({
    super.key,
    required this.rotationDegrees,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow behind
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  PkbTheme.accent.withOpacity(0.35),
                  PkbTheme.accent.withOpacity(0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Tick marks ring
          CustomPaint(
            size: Size(size, size),
            painter: _TickRingPainter(),
          ),
          // Spinning disc
          Transform.rotate(
            angle: rotationDegrees * pi / 180.0,
            child: CustomPaint(
              size: Size(size * 0.82, size * 0.82),
              painter: _DiscPainter(),
            ),
          ),
          // Cardinal marks
          _CardinalMarks(size: size),
          // Central hub
          CustomPaint(
            size: Size(size * 0.26, size * 0.26),
            painter: _HubPainter(),
          ),
          // Triangle pointer at top
          Positioned(
            top: size * 0.01,
            child: CustomPaint(
              size: const Size(18, 22),
              painter: _PointerPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TickRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180.0 - pi / 2;
      final outerR = radius - 4;
      final innerR = radius - 16;
      final p1 = Offset(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle));
      final p2 = Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle));
      canvas.drawLine(p1, p2, paint);
    }

    // Outer ring circle
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiscPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const segments = 12;
    const sweep = (2 * pi) / segments;

    for (int i = 0; i < segments; i++) {
      final startAngle = i * sweep - pi / 2;
      final paint = Paint()
        ..color = i.isEven ? PkbTheme.seg1 : PkbTheme.seg2
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }

    // Subtle segment borders
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < segments; i++) {
      final angle = i * sweep - pi / 2;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardinalMarks extends StatelessWidget {
  final double size;
  const _CardinalMarks({required this.size});

  @override
  Widget build(BuildContext context) {
    final r = size * 0.41 + 4;
    final center = size / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // N - gold
          _CardinalDot(
            left: center - 12,
            top: center - r - 12,
            label: 'N',
            color: PkbTheme.gold,
          ),
          // S
          _CardinalDot(
            left: center - 12,
            top: center + r - 12,
            label: 'S',
            color: Colors.white,
          ),
          // L (East)
          _CardinalDot(
            left: center + r - 12,
            top: center - 12,
            label: 'L',
            color: Colors.white,
          ),
          // O (West)
          _CardinalDot(
            left: center - r - 12,
            top: center - 12,
            label: 'O',
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _CardinalDot extends StatelessWidget {
  final double left;
  final double top;
  final String label;
  final Color color;

  const _CardinalDot({
    required this.left,
    required this.top,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: label == 'N' ? const Color(0xFF5A3A00) : PkbTheme.textColor,
          ),
        ),
      ),
    );
  }
}

class _HubPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // White circle
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Shadow ring
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = PkbTheme.primary.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Compass rose (simplified cross)
    final rosePaint = Paint()
      ..color = PkbTheme.primary.withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // N point (gold)
    final goldPaint = Paint()..color = PkbTheme.gold;

    // Draw 4 diamond points
    void drawDiamond(double angleRad, bool isNorth) {
      final tipDist = r * 0.75;
      final sideDist = r * 0.25;
      final baseDist = r * 0.1;
      final perpAngle = angleRad + pi / 2;

      final tip = Offset(
        center.dx + tipDist * cos(angleRad),
        center.dy + tipDist * sin(angleRad),
      );
      final left = Offset(
        center.dx + sideDist * cos(perpAngle) + baseDist * cos(angleRad),
        center.dy + sideDist * sin(perpAngle) + baseDist * sin(angleRad),
      );
      final right = Offset(
        center.dx - sideDist * cos(perpAngle) + baseDist * cos(angleRad),
        center.dy - sideDist * sin(perpAngle) + baseDist * sin(angleRad),
      );
      final base = Offset(
        center.dx - baseDist * cos(angleRad),
        center.dy - baseDist * sin(angleRad),
      );

      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(base.dx, base.dy)
        ..lineTo(right.dx, right.dy)
        ..close();

      canvas.drawPath(
        path,
        isNorth ? goldPaint : Paint()..color = PkbTheme.primary.withOpacity(0.7),
      );
    }

    drawDiamond(-pi / 2, true);  // North (up)
    drawDiamond(pi / 2, false);  // South
    drawDiamond(0, false);        // East
    drawDiamond(pi, false);       // West

    // Center dot
    canvas.drawCircle(center, r * 0.12, rosePaint..style = PaintingStyle.fill);
    canvas.drawCircle(
      center,
      r * 0.12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = PkbTheme.gold
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
