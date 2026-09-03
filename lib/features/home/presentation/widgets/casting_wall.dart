import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';

class CastingWall extends StatelessWidget {
  const CastingWall({super.key});

  List<_Contestant> _getContestants(BuildContext context) {
    final isEn = isAppEnglish(context);
    return [
      _Contestant(
        'GÜLCE',
        isEn ? 'MAIN VOCAL' : 'ANA VOKAL',
        -0.07,
        0.02,
        0.18,
      ),
      _Contestant(
        'DURU',
        isEn ? 'POWER VOCAL' : 'GÜÇLÜ SES',
        0.045,
        0.19,
        0.05,
      ),
      _Contestant(
        'İDİL',
        isEn ? 'HIDDEN GEM' : 'GİZLİ CEVHER',
        -0.025,
        0.38,
        0.13,
      ),
      _Contestant(
        'ALARA',
        isEn ? 'MAIN DANCER' : 'ANA DANSÇI',
        0.065,
        0.57,
        0.02,
      ),
      _Contestant('DERİN', isEn ? 'CENTER' : 'MERKEZ', -0.045, 0.73, 0.16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final contestants = _getContestants(context);
    return Semantics(
      label: isEn
          ? 'Casting board. Final contenders Gülce, Duru, İdil, Alara, and Derin.'
          : 'Casting panosu. Final adayları Gülce, Duru, İdil, Alara ve Derin.',
      excludeSemantics: true,
      child: MediaQuery.withNoTextScaling(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth * 0.29).clamp(82.0, 146.0);
            return AspectRatio(
              aspectRatio: 1.24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: _DossierBoard()),
                  for (final contestant in contestants)
                    Positioned(
                      left: constraints.maxWidth * contestant.left,
                      top: constraints.maxWidth * contestant.top,
                      child: Transform.rotate(
                        angle: contestant.angle,
                        child: _ContestantCard(
                          contestant: contestant,
                          width: cardWidth,
                        ),
                      ),
                    ),
                  Positioned(
                    left: constraints.maxWidth * 0.04,
                    bottom: constraints.maxWidth * 0.03,
                    child: _CastingNote(
                      text: isEn ? 'Final Stage  ★' : 'Final sahnesi  ★',
                      accent: true,
                    ),
                  ),
                  Positioned(
                    right: constraints.maxWidth * 0.03,
                    bottom: constraints.maxWidth * 0.015,
                    child: Transform.rotate(
                      angle: -0.025,
                      child: _CastingNote(
                        text: isEn
                            ? 'Every choice changes\neverything.'
                            : 'Her karar her şeyi\ndeğiştirir.',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DossierBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.inkSoft.withValues(alpha: 0.78),
        border: Border.all(color: AppColors.line),
      ),
      child: CustomPaint(painter: const _BoardPainter()),
    );
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentSoft.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var x = 28.0; x < size.width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    canvas.drawLine(
      Offset(0, size.height * 0.76),
      Offset(size.width, size.height * 0.76),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ContestantCard extends StatelessWidget {
  const _ContestantCard({required this.contestant, required this.width});

  final _Contestant contestant;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 8),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: const Color(0xFFD8CCD0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.9,
            child: _Silhouette(seed: contestant.name.codeUnitAt(0)),
          ),
          const SizedBox(height: 5),
          Text(
            contestant.name,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              contestant.label,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF7A5B67),
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Silhouette extends StatelessWidget {
  const _Silhouette({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final isEven = seed.isEven;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEven
              ? const [Color(0xFFFF9BC1), Color(0xFF5A1933)]
              : const [Color(0xFF7B2447), Color(0xFFFF6FA8)],
        ),
      ),
      child: const CustomPaint(painter: _SilhouettePainter()),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xDD21101A);
    final headRadius = size.shortestSide * 0.18;
    final headCenter = Offset(size.width / 2, size.height * 0.38);
    canvas.drawCircle(headCenter, headRadius, paint);
    final body = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.83),
      width: size.width * 0.72,
      height: size.height * 0.58,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        body,
        topLeft: Radius.elliptical(size.width * 0.3, size.height * 0.2),
        topRight: Radius.elliptical(size.width * 0.3, size.height * 0.2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CastingNote extends StatelessWidget {
  const _CastingNote({required this.text, this.accent = false});

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      color: accent ? AppColors.accent : AppColors.paper,
      child: Text(
        text,
        style: TextStyle(
          color: accent ? AppColors.accentInk : AppColors.ink,
          fontSize: 10,
          height: 1.15,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Contestant {
  const _Contestant(this.name, this.label, this.angle, this.left, this.top);

  final String name;
  final String label;
  final double angle;
  final double left;
  final double top;
}
