import 'package:flutter/material.dart';

class FloatingClouds extends StatefulWidget {
  const FloatingClouds({super.key});

  @override
  State<FloatingClouds> createState() => _FloatingCloudsState();
}

class _CloudConfig {
  final double left;
  final double top;
  final double width;
  final double height;
  final double amplitude;
  final Duration duration;

  const _CloudConfig({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.amplitude,
    required this.duration,
  });
}

class _FloatingCloudsState extends State<FloatingClouds>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  static const _clouds = [
    _CloudConfig(
      left: -30,
      top: 60,
      width: 180,
      height: 60,
      amplitude: 12,
      duration: Duration(seconds: 9),
    ),
    _CloudConfig(
      left: 160,
      top: 140,
      width: 220,
      height: 70,
      amplitude: 16,
      duration: Duration(seconds: 12),
    ),
    _CloudConfig(
      left: 60,
      top: 220,
      width: 150,
      height: 50,
      amplitude: 10,
      duration: Duration(seconds: 14),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = _clouds.map((c) {
      final ctrl = AnimationController(vsync: this, duration: c.duration);
      ctrl.repeat(reverse: true);
      return ctrl;
    }).toList();

    _animations = List.generate(_clouds.length, (i) {
      return Tween<double>(begin: -_clouds[i].amplitude, end: _clouds[i].amplitude)
          .animate(CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut));
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_clouds.length, (i) {
        final cloud = _clouds[i];
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Positioned(
              left: cloud.left,
              top: cloud.top + _animations[i].value,
              child: child!,
            );
          },
          child: _CloudShape(width: cloud.width, height: cloud.height),
        );
      }),
    );
  }
}

class _CloudShape extends StatelessWidget {
  final double width;
  final double height;

  const _CloudShape({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}
