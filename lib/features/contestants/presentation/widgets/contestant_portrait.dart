import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';

class ContestantPortrait extends StatelessWidget {
  const ContestantPortrait({
    required this.contestant,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final Contestant contestant;
  final double? width;
  final double? height;
  final BoxFit fit;

  static const _palettes = [
    [Color(0xFFFF8AB6), Color(0xFF50172E)],
    [Color(0xFFCB6B94), Color(0xFF2B1320)],
    [Color(0xFFFFAAC8), Color(0xFF7B2447)],
    [Color(0xFF9B5373), Color(0xFFFF6FA8)],
    [Color(0xFFF4A9C4), Color(0xFF3B1726)],
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[(contestant.id - 1) % _palettes.length];
    final placeholder = _PortraitPlaceholder(
      contestant: contestant,
      palette: palette,
    );
    return Semantics(
      image: true,
      label: '${contestant.name} yarışmacı portresi',
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (contestant.portraitAsset == null)
                placeholder
              else
                Image.asset(
                  contestant.portraitAsset!,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) => placeholder,
                ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  color: AppColors.ink.withValues(alpha: 0.78),
                  child: Text(
                    contestant.number,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.paper,
                          letterSpacing: 1,
                        ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 7,
                child: Icon(
                  Icons.auto_awesome,
                  size: 15,
                  color: AppColors.paper.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortraitPlaceholder extends StatelessWidget {
  const _PortraitPlaceholder({
    required this.contestant,
    required this.palette,
  });

  final Contestant contestant;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Text(
              contestant.displayName.substring(0, 1),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.paper.withValues(alpha: 0.18),
                    fontSize: 92,
                  ),
            ),
          ),
          const CustomPaint(painter: _PortraitPainter()),
        ],
      ),
    );
  }
}

class _PortraitPainter extends CustomPainter {
  const _PortraitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.paper.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final silhouettePaint = Paint()..color = const Color(0xD91B0D14);

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.25),
      size.shortestSide * 0.3,
      linePaint,
    );
    final headRadius = size.shortestSide * 0.14;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.37),
      headRadius,
      silhouettePaint,
    );
    final body = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.87),
      width: size.width * 0.72,
      height: size.height * 0.66,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        body,
        topLeft: Radius.elliptical(size.width * 0.32, size.height * 0.18),
        topRight: Radius.elliptical(size.width * 0.32, size.height * 0.18),
      ),
      silhouettePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
