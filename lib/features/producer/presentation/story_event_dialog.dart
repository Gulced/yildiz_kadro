import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';

Future<void> showStoryEventDialog(BuildContext context, {required int day}) {
  final state = GameScope.of(context);
  final record = state.ensureStoryEvent(day);
  if (record.choiceId != null) return Future.value();
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _StoryEventDialog(day: day, event: record.event),
  );
}

class _StoryEventDialog extends StatefulWidget {
  const _StoryEventDialog({required this.day, required this.event});
  final int day;
  final StoryEvent event;

  @override
  State<_StoryEventDialog> createState() => _StoryEventDialogState();
}

class _StoryEventDialogState extends State<_StoryEventDialog> {
  String? selectedId;
  bool resolved = false;

  String name(int id) => contestantSeedData
      .firstWhere((contestant) => contestant.id == id)
      .displayName;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final choice = selectedId == null
        ? null
        : widget.event.choices.firstWhere((item) => item.id == selectedId);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.inkSoft,
      shape: const RoundedRectangleBorder(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_category(widget.event.category), style: _overline(context)),
              const SizedBox(height: AppSpacing.sm),
              Text(widget.event.title,
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: widget.event.contestantIds.map((id) {
                  final contestant =
                      contestantSeedData.firstWhere((value) => value.id == id);
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    ClipOval(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: ContestantPortrait(contestant: contestant),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(contestant.displayName),
                  ]);
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(widget.event.body),
              const SizedBox(height: AppSpacing.md),
              Text('NEDEN?', style: _overline(context)),
              Text(widget.event.why),
              if (widget.event.confessional != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(widget.event.confessional!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.paperMuted,
                        )),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (!resolved)
                ...widget.event.choices.map((option) {
                  final selected = selectedId == option.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InkWell(
                      onTap: () => setState(() => selectedId = option.id),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          border: Border.all(
                            color: selected
                                ? AppColors.accentBright
                                : AppColors.line,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option.label),
                            const SizedBox(height: AppSpacing.xs),
                            Text('BEKLENEN ETKİ', style: _overline(context)),
                            ...state
                                .previewStoryChoice(widget.event, option)
                                .entries
                                .map((entry) => Text(
                                    '${name(entry.key)}  ${_effects(entry.value)}')),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              if (resolved && choice != null) ...[
                Text('KARAR UYGULANDI', style: _overline(context)),
                Text(choice.feedback),
              ],
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: resolved
                    ? () => Navigator.pop(context)
                    : choice == null
                        ? null
                        : () {
                            state.resolveStoryEvent(
                              day: widget.day,
                              choiceId: choice.id,
                            );
                            setState(() => resolved = true);
                          },
                child: Text(resolved ? 'DEVAM ET' : 'KARARI UYGULA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _category(StoryEventCategory value) => switch (value) {
        StoryEventCategory.crisis => 'KRİZ',
        StoryEventCategory.positive => 'OLUMLU GELİŞME',
        StoryEventCategory.social => 'SOSYAL GELİŞME',
        StoryEventCategory.performance => 'PERFORMANS GELİŞMESİ',
        StoryEventCategory.relationship => 'İLİŞKİ OLAYI',
      };

  TextStyle _overline(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright);

  String _effects(Map<String, int> values) => values.entries
      .where((entry) => entry.value != 0)
      .map((entry) =>
          '${_metric(entry.key)} ${entry.value > 0 ? '+' : ''}${entry.value}')
      .join(' • ');

  String _metric(String key) => switch (key) {
        'morale' => 'Motivasyon',
        'popularity' => 'Popülerlik',
        'buzz' => 'Buzz',
        'followers' => 'Takipçi',
        'confidence' => 'Özgüven',
        'professionalism' => 'Profesyonellik',
        'energy' => 'Enerji',
        'preparation' => 'Hazırlık',
        'relationship' => 'İlişki',
        _ => key,
      };
}
