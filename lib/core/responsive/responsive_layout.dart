import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';

enum WindowSize { compact, medium, expanded }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.compact,
    this.medium,
    this.expanded,
    super.key,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  static WindowSize sizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.expanded) return WindowSize.expanded;
    if (width >= AppBreakpoints.compact) return WindowSize.medium;
    return WindowSize.compact;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.expanded) {
          return (expanded ?? medium ?? compact)(context);
        }
        if (constraints.maxWidth >= AppBreakpoints.compact) {
          return (medium ?? compact)(context);
        }
        return compact(context);
      },
    );
  }
}
