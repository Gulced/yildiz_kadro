import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';

class ShowBackground extends StatelessWidget {
  const ShowBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF090709),
        gradient: RadialGradient(
          center: Alignment(0.72, -0.82),
          radius: 1.05,
          colors: [Color(0x99501833), Color(0xFF1A0C13), Color(0xFF090709)],
          stops: [0, 0.36, 0.88],
        ),
      ),
      child: CustomPaint(painter: const _BackstagePainter(), child: child),
    );
  }
}

class _BackstagePainter extends CustomPainter {
  const _BackstagePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.accentSoft.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final starPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.075)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 54);

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.28),
      size.shortestSide * 0.14,
      glowPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.58),
      size.shortestSide * 0.18,
      glowPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.76, 0),
      Offset(size.width, size.height * 0.26),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.9, 0),
      Offset(size.width * 0.68, size.height * 0.32),
      linePaint,
    );

    final center = Offset(size.width * 0.87, size.height * 0.42);
    const outer = 96.0;
    const inner = 42.0;
    final path = Path();
    for (var point = 0; point < 10; point++) {
      final angle = -1.5708 + point * 0.62832;
      final radius = point.isEven ? outer : inner;
      final target = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (point == 0) {
        path.moveTo(target.dx, target.dy);
      } else {
        path.lineTo(target.dx, target.dy);
      }
    }
    path.close();
    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
