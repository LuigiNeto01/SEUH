import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme/pkb_theme.dart';

class NameModal extends StatefulWidget {
  const NameModal({super.key});

  @override
  State<NameModal> createState() => _NameModalState();
}

class _NameModalState extends State<NameModal> {
  final _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final val = _controller.text.trim().isNotEmpty;
      if (val != _canSubmit) {
        setState(() => _canSubmit = val);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    context.read<AppState>().saveName(name);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x8C0D2432),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gold compass rose icon
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: PkbTheme.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: CustomPaint(
                    painter: _CompassRoseIconPainter(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo ao Seuh',
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PkbTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Como podemos te chamar?',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: PkbTheme.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _canSubmit ? _submit() : null,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: PkbTheme.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Seu nome',
                    hintStyle: GoogleFonts.nunito(color: PkbTheme.muted),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: PkbTheme.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: PkbTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: PkbTheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PkbTheme.primary,
                      disabledBackgroundColor: PkbTheme.primary.withOpacity(0.35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Começar',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassRoseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    void drawDiamond(double angleRad, bool isNorth) {
      final tipDist = r * 0.7;
      final sideDist = r * 0.22;
      final baseDist = r * 0.08;
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
        Paint()
          ..color = isNorth ? PkbTheme.gold : PkbTheme.primary.withOpacity(0.7),
      );
    }

    drawDiamond(-pi / 2, true);
    drawDiamond(pi / 2, false);
    drawDiamond(0, false);
    drawDiamond(pi, false);

    canvas.drawCircle(
      center,
      r * 0.1,
      Paint()..color = PkbTheme.gold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
