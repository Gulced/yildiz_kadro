import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/day2/presentation/manual_day2_team_builder_screen.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_team_draft.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_draft_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/group_task/presentation/group_task_rehearsal_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase { briefing, mission, captains, draft, summary }

class Day2BriefingScreen extends StatefulWidget {
  const Day2BriefingScreen({super.key});

  @override
  State<Day2BriefingScreen> createState() => _Day2BriefingScreenState();
}

class _Day2BriefingScreenState extends State<Day2BriefingScreen> {
  _Phase _phase = _Phase.briefing;
  final List<int> _selectedCaptainIds = [];
  int _revealedPicks = 0;
  Timer? _draftTimer;
  bool _confirming = false;

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  List<Contestant> get _activeContestants {
    final eliminated = GameScope.of(context).eliminatedContestantIds;
    return contestantSeedData
        .where((contestant) => !eliminated.contains(contestant.id))
        .toList(growable: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GameScope.of(context).day2TeamFormationCompleted) {
      _phase = _Phase.summary;
    }
  }

  void _selectCaptain(int id) {
    setState(() {
      if (_selectedCaptainIds.contains(id)) {
        _selectedCaptainIds.remove(id);
      } else if (_selectedCaptainIds.length < 2) {
        _selectedCaptainIds.add(id);
      } else {
        _selectedCaptainIds.removeLast();
        _selectedCaptainIds.add(id);
      }
    });
  }

  Future<void> _confirmCaptains() async {
    if (_selectedCaptainIds.length != 2 || _confirming) return;
    final captainA = _contestant(_selectedCaptainIds[0]);
    final captainB = _contestant(_selectedCaptainIds[1]);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      isScrollControlled: true,
      builder: (context) => CaptainConfirmationSheet(
        captainA: captainA,
        captainB: captainB,
        onChange: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    if (confirmed == true && mounted) {
      _confirming = true;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ManualDay2TeamBuilderScreen(
            captainAId: captainA.id,
            captainBId: captainB.id,
          ),
        ),
      );
      if (mounted) {
        setState(() {
          _confirming = false;
          if (GameScope.of(context).day2TeamFormationCompleted) {
            _phase = _Phase.summary;
          }
        });
      }
    }
  }

  void _showAllPicks() {
    _draftTimer?.cancel();
    setState(
      () => _revealedPicks = GameScope.of(context).day2TeamDraftEvents.length,
    );
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _buildPhase(context),
          ),
        ),
      );

  Widget _buildPhase(BuildContext context) {
    switch (_phase) {
      case _Phase.briefing:
        return _Briefing(
          contestants: _activeContestants,
          onNext: () => setState(() => _phase = _Phase.mission),
        );
      case _Phase.mission:
        return _Mission(onNext: () => setState(() => _phase = _Phase.captains));
      case _Phase.captains:
        return _CaptainSelection(
          contestants: _activeContestants,
          selectedIds: _selectedCaptainIds,
          onSelect: _selectCaptain,
          onConfirm: _selectedCaptainIds.length == 2 ? _confirmCaptains : null,
        );
      case _Phase.draft:
        return _DraftReveal(
          revealedPicks: _revealedPicks,
          contestant: _contestant,
          onSkip: _showAllPicks,
          onComplete: _revealedPicks == 12
              ? () => setState(() => _phase = _Phase.summary)
              : null,
        );
      case _Phase.summary:
        return _TeamSummary(contestant: _contestant);
    }
  }
}

class _Briefing extends StatelessWidget {
  const _Briefing({required this.contestants, required this.onNext});
  final List<Contestant> contestants;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dayLabel(2), style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn ? 'FIRST GROUP TASK' : 'İLK GRUP GÖREVİ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isEn ? 'You are no longer alone.' : 'Artık yalnız değilsiniz.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? '14 contestants.\n2 teams.\nOne stage.'
                : '14 yarışmacı.\n2 takım.\nTek sahne.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Today your performance determines not only your score, but your team’s fate.'
                : 'Bugün performansınız yalnızca kendi puanınızı değil, takımınızın kaderini de belirleyecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isEn
                ? 'Being a strong solo star is one thing. Being part of a group is another.'
                : 'Güçlü bir yıldız olmak başka. Bir grubun parçası olmak başka.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PortraitGrid(contestants: contestants),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'LEARN MISSION' : 'GÖREVİ ÖĞREN',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _Mission extends StatelessWidget {
  const _Mission({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? "TODAY'S MISSION" : 'BUGÜNÜN GÖREVİ',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn ? 'GROUP STAGE' : 'GRUP SAHNESİ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isEn
                ? 'Two teams will hit the stage with different arrangements of the same track.'
                : 'İki takım aynı şarkının farklı düzenlemeleriyle sahneye çıkacak.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _Criterion(
            isEn ? 'CHEMISTRY' : 'UYUM',
            isEn
                ? 'Moving and breathing as one unit'
                : 'Birlikte hareket edebilmek',
          ),
          _Criterion(
            isEn ? 'PERFORMANCE' : 'PERFORMANS',
            isEn
                ? 'Vocal, dance, and stage dominance'
                : 'Vokal, dans ve sahne gücü',
          ),
          _Criterion(
            isEn ? 'STAR MOMENT' : 'YILDIZ ANI',
            isEn
                ? 'One member owning the entire stage'
                : 'Takımdan birinin sahneyi sahiplenmesi',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isEn
                ? 'Winning team earns an advantage.\nLosing team carries the night’s elimination risk.'
                : 'Kazanan takım avantaj kazanacak.\nKaybeden takım ise gecenin riskini taşıyacak.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'CHOOSE CAPTAINS' : 'KAPTANLARI SEÇ',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _CaptainSelection extends StatelessWidget {
  const _CaptainSelection({
    required this.contestants,
    required this.selectedIds,
    required this.onSelect,
    required this.onConfirm,
  });
  final List<Contestant> contestants;
  final List<int> selectedIds;
  final ValueChanged<int> onSelect;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final radar = GameScope.of(context).playerRadarContestantIds;
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'PICK TWO CAPTAINS' : 'İKİ KAPTAN SEÇ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'The two contestants you pick will build today’s squads.'
                : 'Bugünün takımlarını senin seçtiğin iki yarışmacı kuracak.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isEn
                ? 'Being a captain doesn’t boost individual score, but determines squad synergy.'
                : 'Kaptan olmak performans bonusu vermez. Ama takımın nasıl kurulacağını değiştirebilir.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? '${selectedIds.length} / 2 CAPTAINS SELECTED'
                : '${selectedIds.length} / 2 KAPTAN SEÇİLDİ',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contestants.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 235,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              final contestant = contestants[index];
              final selectionIndex = selectedIds.indexOf(contestant.id);
              return _CaptainCard(
                contestant: contestant,
                selectionIndex: selectionIndex,
                onRadar: radar.contains(contestant.id),
                onTap: () => onSelect(contestant.id),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: selectedIds.length == 2
                ? (isEn ? 'CONFIRM CAPTAINS' : 'KAPTANLARI ONAYLA')
                : (isEn ? 'PICK 2 CAPTAINS' : '2 KAPTAN SEÇ'),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _DraftReveal extends StatelessWidget {
  const _DraftReveal({
    required this.revealedPicks,
    required this.contestant,
    required this.onSkip,
    required this.onComplete,
  });
  final int revealedPicks;
  final Contestant Function(int) contestant;
  final VoidCallback onSkip;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final events = state.day2TeamDraftEvents;
    final revealed = events.take(revealedPicks).toList();
    final teamA = [
      state.day2CaptainAId!,
      ...revealed
          .where((e) => e.teamId == 'A')
          .map((e) => e.selectedContestantId),
    ];
    final teamB = [
      state.day2CaptainBId!,
      ...revealed
          .where((e) => e.teamId == 'B')
          .map((e) => e.selectedContestantId),
    ];
    final current = revealed.isEmpty ? null : revealed.last;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'FORMING TEAMS' : 'TAKIMLAR KURULUYOR',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DraftTeamColumn(
                  '${isEn ? "TEAM" : "TAKIM"} ${contestant(state.day2CaptainAId!).displayName}',
                  teamA,
                  contestant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DraftTeamColumn(
                  '${isEn ? "TEAM" : "TAKIM"} ${contestant(state.day2CaptainBId!).displayName}',
                  teamB,
                  contestant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (current != null) ...[
            Text(
              current.pickNumber == 12
                  ? (isEn ? 'FINAL PICK' : 'SON SEÇİM')
                  : (isEn
                      ? '${contestant(current.captainId).displayName}’S PICK'
                      : '${contestant(current.captainId).displayName}’İN SEÇİMİ'),
              style: _pinkLabel(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: ContestantPortrait(
                      contestant: contestant(current.selectedContestantId),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contestant(current.selectedContestantId).displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          isEn
                              ? 'Joins Team ${contestant(current.captainId).name}.'
                              : 'Takım ${contestant(current.captainId).name}’e katılıyor.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          current.reason,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                        if (current.pickNumber == 12)
                          Text(
                            isEn
                                ? 'Draft round completed. Time to prove it under the stage lights.'
                                : 'Seçim sırası bitti. Şimdi kendini sahnede gösterme zamanı.',
                            style: _pinkLabel(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (revealedPicks < 12)
            TextButton(
              onPressed: onSkip,
              child: Text(isEn ? 'VIEW ALL TEAMS' : 'TÜM TAKIMLARI GÖR'),
            ),
          AppButton(
            label: revealedPicks == 12
                ? (isEn ? 'INSPECT TEAMS' : 'TAKIMLARI İNCELE')
                : (isEn ? 'DRAFT IN PROGRESS' : 'SEÇİMLER SÜRÜYOR'),
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}

class _TeamSummary extends StatelessWidget {
  const _TeamSummary({required this.contestant});
  final Contestant Function(int) contestant;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final averageA = state.day2TeamAAverages!;
    final averageB = state.day2TeamBAverages!;
    final captainA = contestant(state.day2CaptainAId!);
    final captainB = contestant(state.day2CaptainBId!);
    final difference = (averageA.overall - averageB.overall).abs();
    final radar = state.playerRadarContestantIds.where(
      (id) => !state.eliminatedContestantIds.contains(id),
    );
    final radarA = radar.where(state.day2TeamAIds.contains).toList();
    final radarB = radar.where(state.day2TeamBIds.contains).toList();
    final eliminatedRadarCount = state.playerRadarContestantIds
        .where(state.eliminatedContestantIds.contains)
        .length;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'TEAMS ASSEMBLED' : 'TAKIMLAR HAZIR',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _FullTeamCard(
                  captain: captainA,
                  ids: state.day2TeamAIds,
                  averages: averageA,
                  contestant: contestant,
                ),
                _FullTeamCard(
                  captain: captainB,
                  ids: state.day2TeamBIds,
                  averages: averageB,
                  contestant: contestant,
                ),
              ];
              if (constraints.maxWidth < AppBreakpoints.compact) {
                return Column(
                  children: [
                    cards.first,
                    const SizedBox(height: AppSpacing.md),
                    cards.last,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards.first),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: cards.last),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            isEn ? 'TEAM BALANCE' : 'TAKIM DENGESİ',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _ComparisonRow(
            context.l10n.vocal.toUpperCase(),
            averageA.vocal,
            averageB.vocal,
          ),
          _ComparisonRow(
            context.l10n.dance.toUpperCase(),
            averageA.dance,
            averageB.dance,
          ),
          _ComparisonRow(
            context.l10n.stage.toUpperCase(),
            averageA.stage,
            averageB.stage,
          ),
          _ComparisonRow(
            isEn ? 'OVERALL' : 'GENEL',
            averageA.overall,
            averageB.overall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            difference > 3
                ? (isEn
                    ? 'One squad leads on paper.\nYet on group night, synergy often outweighs pure raw stats.'
                    : 'Kağıt üzerinde bir takım önde.\nAma grup görevinde uyum puanlardan daha önemli olabilir.')
                : (isEn
                    ? 'Neck and neck on paper.'
                    : 'Kağıt üzerinde başa baş.'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            isEn ? 'YOUR RADAR' : 'SENİN RADARIN',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          _RadarTeam(
            '${isEn ? "TEAM" : "TAKIM"} ${captainA.displayName}',
            radarA,
            contestant,
          ),
          _RadarTeam(
            '${isEn ? "TEAM" : "TAKIM"} ${captainB.displayName}',
            radarB,
            contestant,
          ),
          if (eliminatedRadarCount > 0)
            Text(
              isEn
                  ? '$eliminatedRadarCount names on your radar are no longer in the competition.'
                  : 'Radarındaki $eliminatedRadarCount isim artık yarışmada değil.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.paperMuted,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            isEn
                ? 'You picked the captains.\nThey built their squads.'
                : 'Kaptanları sen seçtin.\nTakımları onlar kurdu.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn
                ? 'Now see what that choice turns into on stage.'
                : 'Şimdi bu kararın sahnede neye dönüşeceğini göreceksin.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            isEn ? 'ALL EYES ON' : 'GÖZLER ÜZERİNDE',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LastPickedCard(contestant(state.day2LastPickedContestantId!)),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'GO TO REHEARSAL' : 'PROVAYA GEÇ',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GroupTaskRehearsalScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullTeamCard extends StatelessWidget {
  const _FullTeamCard({
    required this.captain,
    required this.ids,
    required this.averages,
    required this.contestant,
  });
  final Contestant captain;
  final List<int> ids;
  final TeamAverages averages;
  final Contestant Function(int) contestant;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              teamProfileLabel(averages, context),
              style: _pinkLabel(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...ids.map(
              (id) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      height: 54,
                      child: ContestantPortrait(contestant: contestant(id)),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        contestant(id).displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (id == captain.id)
                      Text(
                        isEn ? 'CAPTAIN' : 'KAPTAN',
                        style: _pinkLabel(context),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow(this.label, this.a, this.b);
  final String label;
  final double a;
  final double b;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child:
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
            ),
            Expanded(
              child: Text(
                a.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: Text(
                b.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      );
}

class _RadarTeam extends StatelessWidget {
  const _RadarTeam(this.label, this.ids, this.contestant);
  final String label;
  final List<int> ids;
  final Contestant Function(int) contestant;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
            ),
            Expanded(
              child: Text(
                ids.isEmpty
                    ? '—'
                    : ids.map((id) => '★ ${contestant(id).name}').join('\n'),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
}

class _LastPickedCard extends StatelessWidget {
  const _LastPickedCard(this.contestant);
  final Contestant contestant;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Container(
      height: 180,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contestant.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isEn
                      ? 'Drafted last in team selection.'
                      : 'Takım seçiminde adı en son söylendi.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  isEn
                      ? 'Let’s see if she channels that into fierce stage motivation.'
                      : 'Bakalım bunu sahnede motivasyona çevirebilecek mi?',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftTeamColumn extends StatelessWidget {
  const _DraftTeamColumn(this.label, this.ids, this.contestant);
  final String label;
  final List<int> ids;
  final Contestant Function(int) contestant;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text('${ids.length} / 7', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          ...ids.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 44,
                    child: ContestantPortrait(contestant: contestant(id)),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      contestant(id).displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _CaptainCard extends StatelessWidget {
  const _CaptainCard({
    required this.contestant,
    required this.selectionIndex,
    required this.onRadar,
    required this.onTap,
  });
  final Contestant contestant;
  final int selectionIndex;
  final bool onRadar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final profile = groupTaskProfiles[contestant.id]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(
            color:
                selectionIndex >= 0 ? AppColors.accentBright : AppColors.line,
            width: selectionIndex >= 0 ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ContestantPortrait(contestant: contestant)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${contestant.displayName} — ${contestant.age}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              '${isEn ? "OVERALL" : "GENEL"} ${evaluation1Results[contestant.id]!.overall} • ${_roleLabel(profile.primaryRole, context)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _pinkLabel(context),
            ),
            if (onRadar)
              Text(
                isEn ? '★ ON RADAR' : '★ RADARINDA',
                style: _pinkLabel(context),
              ),
            if (selectionIndex >= 0)
              Text(
                isEn
                    ? 'CAPTAIN ${selectionIndex + 1}'
                    : '${selectionIndex + 1}. KAPTAN',
                style: _pinkLabel(context),
              ),
          ],
        ),
      ),
    );
  }
}

class CaptainConfirmationSheet extends StatelessWidget {
  const CaptainConfirmationSheet({
    required this.captainA,
    required this.captainB,
    required this.onChange,
    required this.onConfirm,
    super.key,
  });

  final Contestant captainA;
  final Contestant captainB;
  final VoidCallback onChange;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: availableHeight * .88,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  Text(
                    isEn ? 'CAPTAINS READY' : 'KAPTANLARIN HAZIR',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _CaptainConfirmCard(
                                  captainA,
                                  isEn ? 'CAPTAIN A' : 'KAPTAN A',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _CaptainConfirmCard(
                                  captainB,
                                  isEn ? 'CAPTAIN B' : 'KAPTAN B',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            isEn
                                ? 'These two contestants will now take turns drafting their teams.'
                                : 'Bu iki yarışmacı şimdi takımlarını sırayla kuracak.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: onChange,
                          child: Text(isEn ? 'CHANGE' : 'DEĞİŞTİR'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: onConfirm,
                          child: Text(
                            isEn ? 'START TEAM DRAFT' : 'TAKIM SEÇİMİNİ BAŞLAT',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
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

class _CaptainConfirmCard extends StatelessWidget {
  const _CaptainConfirmCard(this.contestant, this.label);
  final Contestant contestant;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          AspectRatio(
            aspectRatio: 0.85,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            contestant.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(label, style: _pinkLabel(context)),
        ],
      );
}

class _PortraitGrid extends StatelessWidget {
  const _PortraitGrid({required this.contestants});
  final List<Contestant> contestants;

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: contestants.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisExtent: 115,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (context, index) =>
            ContestantPortrait(contestant: contestants[index]),
      );
}

class _Criterion extends StatelessWidget {
  const _Criterion(this.title, this.description);
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _pinkLabel(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: MaxWidthContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: context.l10n.back,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: AppSpacing.sm),
                child,
              ],
            ),
          ),
        ),
      );
}

String _roleLabel(GroupRole role, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (role) {
    GroupRole.vocal => isEn ? 'VOCAL' : 'VOKAL',
    GroupRole.dance => isEn ? 'DANCE' : 'DANS',
    GroupRole.stage => isEn ? 'STAGE' : 'SAHNE',
    GroupRole.allRounder => isEn ? 'ALL-ROUNDER' : 'ÇOK YÖNLÜ',
  };
}

TextStyle? _pinkLabel(BuildContext context) => Theme.of(context)
    .textTheme
    .labelMedium
    ?.copyWith(color: AppColors.accentSoft, letterSpacing: 0.8);
