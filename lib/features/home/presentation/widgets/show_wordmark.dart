import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';

class ShowWordmark extends StatelessWidget {
  const ShowWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Yıldız Kadro',
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            'YILDIZ\nKADRO',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'serif',
                  fontSize: 32,
                  height: 0.78,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
          ),
          Positioned(
            top: -9,
            left: 85,
            child: Transform.rotate(
              angle: 0.2,
              child: const Icon(
                Icons.auto_awesome,
                size: 17,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
