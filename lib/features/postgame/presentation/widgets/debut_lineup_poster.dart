import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';

class DebutLineupPoster extends StatelessWidget {
  const DebutLineupPoster({
    required this.memberIds,
    this.height = 390,
    super.key,
  });
  final List<int> memberIds;
  final double height;

  @override
  Widget build(BuildContext context) {
    assert(memberIds.length == 5);
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth * .29).clamp(92.0, 210.0);
        return Container(
          height: height,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [AppColors.accentInk, AppColors.ink],
            ),
          ),
          child: ClipRect(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: 22,
                  child: Text(
                    '✦',
                    style: TextStyle(
                      fontSize: 28,
                      color: AppColors.accentSoft.withValues(alpha: .7),
                    ),
                  ),
                ),
                for (var i = 0; i < memberIds.length; i++)
                  Positioned(
                    left: constraints.maxWidth / 2 -
                        itemWidth / 2 +
                        (i - 2) * itemWidth * .66,
                    bottom: i == 2
                        ? 18
                        : i.isOdd
                            ? 0
                            : 8,
                    child: SizedBox(
                      width: itemWidth,
                      height: height * (i == 2 ? .79 : .71),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0, .78, 1],
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: ContestantPortrait(
                          contestant: contestantSeedData.firstWhere(
                            (value) => value.id == memberIds[i],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Text(
                    isAppEnglish(context) ? 'STAR LINEUP' : 'YILDIZ KADRO',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 38,
                      letterSpacing: -1.5,
                      shadows: const [
                        Shadow(color: AppColors.ink, blurRadius: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
