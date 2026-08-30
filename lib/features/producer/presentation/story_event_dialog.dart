import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';

Future<void> showStoryEventDialog(BuildContext context, {required int day}) {
  final state = GameScope.of(context);
  final record = state.prepareStoryEvent(day);
  if (record == null) return Future.value();
  if (record.choiceId != null) return Future.value();
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.68),
    builder: (_) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: _StoryEventDialog(day: day, event: record.event),
    ),
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
              Text(
                widget.event.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: widget.event.contestantIds.map((id) {
                  final contestant = contestantSeedData.firstWhere(
                    (value) => value.id == id,
                  );
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: ContestantPortrait(contestant: contestant),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(contestant.displayName),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(widget.event.body),
              const SizedBox(height: AppSpacing.md),
              Text('NEDEN?', style: _overline(context)),
              Text(widget.event.why),
              if (widget.event.confessional != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.event.confessional!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.paperMuted,
                      ),
                ),
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
                            Text(
                              option.label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              if (resolved && choice != null) ...[
                Text('KARAR UYGULANDI', style: _overline(context)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  choice.feedback,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                ..._resultChanges(state).map(
                  (change) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        Icon(
                          change.delta > 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 18,
                          color: change.delta > 0
                              ? Colors.greenAccent
                              : AppColors.accentBright,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text('${change.name} • ${change.metric}'),
                        ),
                        Text(
                          '${change.delta > 0 ? '+' : ''}${_displayValue(change.metricKey, change.delta)}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
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

  List<({String name, String metric, String metricKey, int delta})>
      _resultChanges(GameState state) {
    final record = state.storyEventForDay(widget.day);
    if (record == null || record.choiceId == null) return const [];
    final changes =
        <({String name, String metric, String metricKey, int delta})>[];
    for (final id in record.event.contestantIds) {
      final before = record.before[id] ?? const <String, int>{};
      final after = record.after[id] ?? const <String, int>{};
      for (final entry in after.entries) {
        final previous = before[entry.key];
        if (previous == null || previous == entry.value) continue;
        changes.add((
          name: name(id),
          metric: _metric(entry.key),
          metricKey: entry.key,
          delta: entry.value - previous,
        ));
      }
    }
    return changes;
  }

  String _displayValue(String key, int value) {
    if (key != 'followers') return '$value';
    final sign = value < 0 ? '-' : '';
    return '$sign${(value.abs() / 1000).toStringAsFixed(value.abs() < 10000 ? 1 : 0)}K';
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

  String _metric(String key) => switch (key) {
        'morale' || 'motivation' => 'Motivasyon',
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
