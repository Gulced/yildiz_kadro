import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';

class MissionBriefing extends StatefulWidget {
  const MissionBriefing({
    required this.stageId,
    required this.title,
    required this.what,
    required this.watch,
    required this.affects,
    required this.child,
    super.key,
  });
  final String stageId;
  final String title;
  final String what;
  final String watch;
  final String affects;
  final Widget child;

  @override
  State<MissionBriefing> createState() => _MissionBriefingState();
}

class _MissionBriefingState extends State<MissionBriefing> {
  bool scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    if (!scheduled && !state.hasSeenMissionBriefing(widget.stageId)) {
      scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GameScope.of(context).markMissionBriefingSeen(widget.stageId);
          _show();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Stack(
      children: [
        widget.child,
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 8,
          end: 62,
          child: SafeArea(
            top: false,
            child: TextButton.icon(
              onPressed: _show,
              icon: const Icon(Icons.help_outline_rounded, size: 18),
              label: Text(isEn ? 'MISSION' : 'GÖREV'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _show() => showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final isEn = isAppEnglish(dialogContext);
          return Dialog(
            backgroundColor: AppColors.inkSoft,
            shape: const RoundedRectangleBorder(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEn ? 'MISSION BRIEF' : 'GÖREV ÖZETİ',
                            style: _label(dialogContext),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _line(
                      dialogContext,
                      isEn ? 'WHAT TO DO' : 'NE YAPACAKSIN?',
                      widget.what,
                    ),
                    _line(
                      dialogContext,
                      isEn ? 'WHAT TO WATCH' : 'NELERE DİKKAT ET?',
                      widget.watch,
                    ),
                    _line(
                      dialogContext,
                      isEn ? 'WHAT IT AFFECTS' : 'NEYİ ETKİLER?',
                      widget.affects,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget _line(BuildContext context, String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _label(context)),
              const SizedBox(height: AppSpacing.xs),
              Text(body),
            ],
          ),
        ),
      );

  TextStyle _label(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
}
