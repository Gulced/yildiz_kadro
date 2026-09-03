import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/evaluation/presentation/first_evaluation_screen.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class FirstImpressionTransitionScreen extends StatefulWidget {
  const FirstImpressionTransitionScreen({super.key});

  @override
  State<FirstImpressionTransitionScreen> createState() =>
      _FirstImpressionTransitionScreenState();
}

class _FirstImpressionTransitionScreenState
    extends State<FirstImpressionTransitionScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), _openEvaluation);
  }

  void _openEvaluation() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const FirstEvaluationScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: MaxWidthContainer(
          maxWidth: 620,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accentBright,
                    size: 34,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.firstImpressionsComplete,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 42),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.stageLightsChangeEverything,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.firstEvaluationStarting.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.accentSoft,
                          letterSpacing: 1.2,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
