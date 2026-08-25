import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';

class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding =
        width >= AppBreakpoints.compact ? AppSpacing.xxl : AppSpacing.lg;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
