import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_rehearsal_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_rehearsal.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day2_group_performance_screen.dart';
import 'package:yildiz_kadro/features/producer/presentation/story_event_dialog.dart';
import 'package:yildiz_kadro/features/producer/presentation/widgets/performance_aftermath_panel.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase { intro, rolesIntro, teamA, teamB, metrics, crises, choice, result }

class GroupTaskRehearsalScreen extends StatefulWidget {
  const GroupTaskRehearsalScreen({super.key});

  @override
  State<GroupTaskRehearsalScreen> createState() =>
      _GroupTaskRehearsalScreenState();
}

class _GroupTaskRehearsalScreenState extends State<GroupTaskRehearsalScreen> {
  _Phase _phase = _Phase.intro;
  String? _selectedInterventionTeamId;
  String? _selectedChoiceId;
  final Map<String, String> _choiceByTeam = {};
  bool _submitting = false;
  bool _storyEventScheduled = false;

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    if (state.day2RehearsalSetup == null) {
      state.initializeDay2Rehearsal(
        initializeDay2Rehearsal(
          teamAIds: state.day2TeamAIds,
          teamBIds: state.day2TeamBIds,
          captainAId: state.day2CaptainAId!,
          captainBId: state.day2CaptainBId!,
          lastPickedContestantId: state.day2LastPickedContestantId!,
          evaluationResults: evaluation1Results,
        ),
      );
    }
    if (!_storyEventScheduled && !state.day2RehearsalCompleted) {
      _storyEventScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showStoryEventDialog(context, day: 2);
      });
    }
    if (state.day2RehearsalCompleted) _phase = _Phase.result;
    if (!state.day2RehearsalCompleted &&
        state.day2PlayerInterventionTeamId != null &&
        _phase.index < _Phase.choice.index) {
      if (state.day2PlayerInterventionTeamId == 'BOTH') {
        _phase = _Phase.crises;
      } else {
        _selectedInterventionTeamId = state.day2PlayerInterventionTeamId;
        _phase = _Phase.choice;
      }
    }
  }

  Future<void> _confirmInterventionTeam(String teamId) async {
    final state = GameScope.of(context);
    if (state.day2PlayerInterventionTeamId == null) {
      state.lockDay2PlayerInterventionTeam('BOTH');
    }
    setState(() {
      _selectedInterventionTeamId = teamId;
      _selectedChoiceId = null;
      _phase = _Phase.choice;
    });
  }

  Future<void> _confirmChoice() async {
    if (_selectedChoiceId == null || _submitting) return;
    final setup = GameScope.of(context).day2RehearsalSetup!;
    final crisis = _selectedInterventionTeamId == 'A'
        ? setup.teamACrisis
        : setup.teamBCrisis;
    final choice = choicesForCrisis(crisis.type)
        .firstWhere((choice) => choice.id == _selectedChoiceId);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      builder: (context) {
        final isEn = isAppEnglish(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'REHEARSAL DECISION' : 'PROVA KARARIN',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  choice.localizedTitle(context),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isEn
                      ? 'This decision will impact the rehearsal outcome.'
                      : 'Bu karar prova sonucuna yansıyacak.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(isEn ? 'GO BACK' : 'GERİ DÖN'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(isEn ? 'APPLY DECISION' : 'KARARI UYGULA'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true && mounted) {
      final state = GameScope.of(context);
      _choiceByTeam[_selectedInterventionTeamId!] = _selectedChoiceId!;
      if (_choiceByTeam.length == 1) {
        final nextTeam = _selectedInterventionTeamId == 'A' ? 'B' : 'A';
        setState(() {
          _selectedInterventionTeamId = nextTeam;
          _selectedChoiceId = null;
          _phase = _Phase.choice;
        });
      } else {
        _submitting = true;
        final outcome = resolveBothDay2Rehearsals(
          setup: setup,
          teamAChoiceId: _choiceByTeam['A']!,
          teamBChoiceId: _choiceByTeam['B']!,
        );
        state.completeDay2Rehearsal(outcome);
        setState(() => _phase = _Phase.result);
      }
    }
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
    final state = GameScope.of(context);
    final setup = state.day2RehearsalSetup!;
    switch (_phase) {
      case _Phase.intro:
        return _Intro(
          contestant: _contestant,
          onNext: () => setState(() => _phase = _Phase.rolesIntro),
        );
      case _Phase.rolesIntro:
        return _RolesIntro(onNext: () => setState(() => _phase = _Phase.teamA));
      case _Phase.teamA:
        return _TeamRoles(
          captain: _contestant(state.day2CaptainAId!),
          roles: setup.teamARoles,
          contestant: _contestant,
          onNext: () => setState(() => _phase = _Phase.teamB),
        );
      case _Phase.teamB:
        return _TeamRoles(
          captain: _contestant(state.day2CaptainBId!),
          roles: setup.teamBRoles,
          contestant: _contestant,
          onNext: () => setState(() => _phase = _Phase.metrics),
        );
      case _Phase.metrics:
        return _InitialMetrics(
          contestant: _contestant,
          onNext: () => setState(() => _phase = _Phase.crises),
        );
      case _Phase.crises:
        return _CrisisSelection(
          contestant: _contestant,
          onSelect: _confirmInterventionTeam,
        );
      case _Phase.choice:
        final crisis = _selectedInterventionTeamId == 'A'
            ? setup.teamACrisis
            : setup.teamBCrisis;
        return _PlayerChoice(
          crisis: crisis,
          selectedChoiceId: _selectedChoiceId,
          onSelect: (id) => setState(() => _selectedChoiceId = id),
          onConfirm: _selectedChoiceId == null ? null : _confirmChoice,
        );
      case _Phase.result:
        return _RehearsalResult(contestant: _contestant);
    }
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.contestant, required this.onNext});
  final Contestant Function(int) contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dayLabel(2), style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn ? 'REHEARSAL' : 'PROVA',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.accentSoft),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn ? 'First cracks begin here.' : 'İlk çatlaklar burada başlar.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isEn
                ? 'Teams are set.\nNow everyone must find their footing on the same stage.'
                : 'Takımlar kuruldu.\nŞimdi herkes aynı sahnede yerini bulmak zorunda.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isEn
                ? 'A great lineup is more than just stacked individual stars.'
                : 'İyi bir kadro yalnızca güçlü isimlerden oluşmaz.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _TeamPreview(
            captain: contestant(state.day2CaptainAId!),
            ids: state.day2TeamAIds,
            contestant: contestant,
          ),
          const SizedBox(height: AppSpacing.md),
          _TeamPreview(
            captain: contestant(state.day2CaptainBId!),
            ids: state.day2TeamBIds,
            contestant: contestant,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'START REHEARSAL' : 'PROVAYI BAŞLAT',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _RolesIntro extends StatelessWidget {
  const _RolesIntro({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn
                ? 'EVERYONE HAS A PLACE ON STAGE'
                : 'SAHNEDE HERKESİN BİR YERİ VAR',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Each member shoulders a distinct role in the performance.'
                : 'Her üye performansta ayrı bir sorumluluk taşıyacak.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _RoleDescription(
            'CENTER',
            isEn
                ? 'The visual focal point of the stage.'
                : 'Performansın görsel odağı.',
          ),
          _RoleDescription(
            isEn ? 'LEAD VOCAL' : 'LEAD VOKAL',
            isEn
                ? 'Carries the song’s most challenging vocal sections.'
                : 'Şarkının en güçlü vokal bölümlerini taşıyor.',
          ),
          _RoleDescription(
            isEn ? 'SUB VOCAL' : 'SUB VOKAL',
            isEn
                ? 'Supports the vocal line and anchors harmonies.'
                : 'Vokal hattını ve diğer bölümleri destekliyor.',
          ),
          _RoleDescription(
            'LEAD DANCER',
            isEn
                ? 'Steps forward during demanding choreography moments.'
                : 'Koreografinin zor anlarında öne çıkıyor.',
          ),
          _RoleDescription(
            'SUB DANCER',
            isEn
                ? 'Maintains formation cohesion and dance synergy.'
                : 'Dans formasyonunun bütünlüğünü destekliyor.',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'ASSIGN ROLES' : 'ROLLERİ DAĞIT',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _TeamRoles extends StatelessWidget {
  const _TeamRoles({
    required this.captain,
    required this.roles,
    required this.contestant,
    required this.onNext,
  });
  final Contestant captain;
  final TeamRoleAssignments roles;
  final Contestant Function(int) contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn ? 'ROLE DISTRIBUTION' : 'ROL DAĞILIMI',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (roles.roleSlots.isNotEmpty)
            ...roles.roleSlots.map(
              (entry) => _RoleHolder(
                day2TeamRoleLabel(entry.slot.type, context),
                day2TeamRoleDescription(entry.slot.type, context),
                contestant(entry.contestantId),
              ),
            )
          else ...[
            _RoleHolder(
              'CENTER',
              isEn ? 'At the center of the camera.' : 'Kameranın merkezinde.',
              contestant(roles.centerId),
            ),
            _RoleHolder(
              isEn ? 'LEAD VOCAL' : 'ANA VOKAL',
              isEn
                  ? 'Anchors the song’s most critical moments.'
                  : 'Şarkının en kritik anları onda.',
              contestant(roles.mainVocalId),
            ),
            _RoleHolder(
              isEn ? 'LEAD DANCER' : 'DANS LİDERİ',
              isEn
                  ? 'Choreography built to her tempo.'
                  : 'Koreografi onun temposuyla kurulacak.',
              contestant(roles.danceLeadId),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isEn ? 'GROUP MEMBERS' : 'GRUP ÜYELERİ',
              style: _pinkLabel(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: roles.groupMemberIds
                  .map(
                    (id) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: .75,
                              child: ContestantPortrait(
                                contestant: contestant(id),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contestant(id).displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isEn
                  ? 'Anchoring the team’s formation unity.'
                  : 'Takımın bütünlüğünü taşıyor.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: isEn ? 'CONTINUE' : 'DEVAM ET', onPressed: onNext),
        ],
      ),
    );
  }
}

class _InitialMetrics extends StatelessWidget {
  const _InitialMetrics({required this.contestant, required this.onNext});
  final Contestant Function(int) contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final setup = state.day2RehearsalSetup!;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'REHEARSAL BEGINS' : 'PROVA BAŞLIYOR',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Both squads revealed their distinct working rhythms from the opening minutes.'
                : 'İki takımın çalışma biçimi ilk dakikalarda kendini gösterdi.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _MetricCard(
            captain: contestant(state.day2CaptainAId!),
            metrics: setup.teamAInitialMetrics,
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricCard(
            captain: contestant(state.day2CaptainBId!),
            metrics: setup.teamBInitialMetrics,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'OPEN REHEARSAL ROOMS' : 'PROVA ODALARINI AÇ',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _CrisisSelection extends StatelessWidget {
  const _CrisisSelection({required this.contestant, required this.onSelect});
  final Contestant Function(int) contestant;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final setup = state.day2RehearsalSetup!;
    final cards = [
      _CrisisCard(
        captain: contestant(state.day2CaptainAId!),
        crisis: setup.teamACrisis,
        contestant: contestant,
        onTap: () => onSelect('A'),
      ),
      _CrisisCard(
        captain: contestant(state.day2CaptainBId!),
        crisis: setup.teamBCrisis,
        contestant: contestant,
        onTap: () => onSelect('B'),
      ),
    ];
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'TWO TEAMS. TWO PROBLEMS.' : 'İKİ TAKIM. İKİ SORUN.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'This time you will step into both rehearsal rooms yourself.'
                : 'Bu kez iki prova odasına da sen gireceksin.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
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
        ],
      ),
    );
  }
}

class _PlayerChoice extends StatelessWidget {
  const _PlayerChoice({
    required this.crisis,
    required this.selectedChoiceId,
    required this.onSelect,
    required this.onConfirm,
  });
  final RehearsalCrisis crisis;
  final String? selectedChoiceId;
  final ValueChanged<String> onSelect;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final choices = choicesForCrisis(crisis.type);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'REHEARSAL DECISION' : 'PROVA KARARI',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            crisis.localizedTitle(context),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'This time you call the shot.'
                : 'Bu kez yönü sen belirleyeceksin.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ...choices.map(
            (choice) => GestureDetector(
              onTap: () => onSelect(choice.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.inkSoft,
                  border: Border.all(
                    color: selectedChoiceId == choice.id
                        ? AppColors.accentBright
                        : AppColors.line,
                    width: selectedChoiceId == choice.id ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice.localizedTitle(context),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      choice.localizedDescription(context),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (selectedChoiceId == choice.id) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        isEn ? '★ SELECTED' : '★ SEÇİLDİ',
                        style: _pinkLabel(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: selectedChoiceId == null
                ? (isEn ? 'PICK A DECISION' : 'BİR KARAR SEÇ')
                : (isEn ? 'APPLY MY DECISION' : 'KARARIMI UYGULA'),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _RehearsalResult extends StatelessWidget {
  const _RehearsalResult({required this.contestant});
  final Contestant Function(int) contestant;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final setup = state.day2RehearsalSetup!;
    final outcome = state.day2RehearsalOutcome!;
    final captainA = contestant(state.day2CaptainAId!);
    final captainB = contestant(state.day2CaptainBId!);
    final scoreA = outcome.teamAFinalMetrics.score;
    final scoreB = outcome.teamBFinalMetrics.score;
    final spotlight = <({Contestant contestant, String role})>[];
    void addSpotlights(TeamRoleAssignments roles) {
      final radar = state.playerRadarContestantIds;
      if (radar.contains(roles.centerId)) {
        spotlight.add((contestant: contestant(roles.centerId), role: 'CENTER'));
      }
      if (radar.contains(roles.mainVocalId)) {
        spotlight.add((
          contestant: contestant(roles.mainVocalId),
          role: isEn ? 'LEAD VOCAL' : 'ANA VOKAL',
        ));
      }
      if (radar.contains(roles.danceLeadId)) {
        spotlight.add((
          contestant: contestant(roles.danceLeadId),
          role: isEn ? 'LEAD DANCER' : 'DANS LİDERİ',
        ));
      }
    }

    addSpotlights(setup.teamARoles);
    addSpotlights(setup.teamBRoles);
    final lastPickCrisis =
        setup.teamACrisis.type == RehearsalCrisisType.lastPickPressure ||
            setup.teamBCrisis.type == RehearsalCrisisType.lastPickPressure;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'REHEARSAL CONCLUDED' : 'PROVA TAMAMLANDI',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Final status before taking the stage.'
                : 'Sahneye çıkmadan önce son durum.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _FinalMetricCard(
            captain: captainA,
            metrics: outcome.teamAFinalMetrics,
            badge: isEn ? '★ YOU INTERVENED' : '★ SEN MÜDAHALE ETTİN',
            narrative:
                (outcome.playerChoicesByTeam['A'] ?? outcome.playerChoice)
                    .localizedNarrative(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _FinalMetricCard(
            captain: captainB,
            metrics: outcome.teamBFinalMetrics,
            badge: isEn ? '★ YOU INTERVENED' : '★ SEN MÜDAHALE ETTİN',
            narrative:
                (outcome.playerChoicesByTeam['B'] ?? outcome.captainChoice)
                    .localizedNarrative(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            scoreA == scoreB
                ? (isEn ? 'TIED IN REHEARSAL' : 'PROVADA BAŞA BAŞ')
                : '${isEn ? "AHEAD IN REHEARSAL: TEAM" : "PROVADA ÖNDE: TAKIM"} ${(scoreA > scoreB ? captainA : captainB).displayName}',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.accentBright),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isEn
                ? 'Yet rehearsal scores never guarantee stage victory.'
                : 'Ama prova puanı sahne sonucunu garanti etmez.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          if (spotlight.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              isEn ? 'RADAR SPOTLIGHT' : 'RADARINDA SPOTLIGHT',
              style: _pinkLabel(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...spotlight.map(
              (item) => Text(
                '★ ${item.contestant.displayName} — ${item.role}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
          if (lastPickCrisis) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              isEn ? 'ALL EYES WERE ON HER' : 'GÖZLER ÜZERİNDEYDİ',
              style: _pinkLabel(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isEn
                  ? '${contestant(state.day2LastPickedContestantId!).name} was drafted last. Rehearsal brought her right back into the game.'
                  : '${contestant(state.day2LastPickedContestantId!).name}, takım seçiminde son sıradaydı. Prova onu yeniden oyuna soktu.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const PerformanceAftermathPanel(stageId: 'day2_rehearsal', limit: 4),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'TAKE THE STAGE' : 'SAHNEYE ÇIK',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Day2GroupPerformanceScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPreview extends StatelessWidget {
  const _TeamPreview({
    required this.captain,
    required this.ids,
    required this.contestant,
  });
  final Contestant captain;
  final List<int> ids;
  final Contestant Function(int) contestant;

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
                '${Localizations.localeOf(context).languageCode == "en" ? "TEAM" : "TAKIM"} ${captain.displayName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: ids
                    .map(
                      (id) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: AspectRatio(
                            aspectRatio: .72,
                            child:
                                ContestantPortrait(contestant: contestant(id)),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
}

class _RoleDescription extends StatelessWidget {
  const _RoleDescription(this.title, this.description);
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

class _RoleHolder extends StatelessWidget {
  const _RoleHolder(this.role, this.caption, this.contestant);
  final String role;
  final String caption;
  final Contestant contestant;

  @override
  Widget build(BuildContext context) => Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            SizedBox(
                width: 110, child: ContestantPortrait(contestant: contestant)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: _pinkLabel(context)),
                  Text(
                    contestant.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    caption,
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.captain, required this.metrics});
  final Contestant captain;
  final RehearsalMetrics metrics;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Localizations.localeOf(context).languageCode == "en" ? "TEAM" : "TAKIM"} ${captain.displayName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _MetricBar('UYUM', metrics.harmony),
            _MetricBar('HAZIRLIK', metrics.readiness),
            _MetricBar('ENERJİ', metrics.energy),
          ],
        ),
      );
}

class _MetricBar extends StatelessWidget {
  const _MetricBar(this.label, this.value);
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 78,
              child:
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: value / 100,
                  minHeight: 7,
                  backgroundColor: AppColors.line,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
                width: 28, child: Text('$value', textAlign: TextAlign.right)),
          ],
        ),
      );
}

class _CrisisCard extends StatelessWidget {
  const _CrisisCard({
    required this.captain,
    required this.crisis,
    required this.contestant,
    required this.onTap,
  });
  final Contestant captain;
  final RehearsalCrisis crisis;
  final Contestant Function(int) contestant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final people = [
      crisis.primaryContestantId,
      if (crisis.secondaryContestantId != null) crisis.secondaryContestantId!,
    ];
    final primary = contestant(crisis.primaryContestantId);
    final secondary = crisis.secondaryContestantId == null
        ? null
        : contestant(crisis.secondaryContestantId!);
    final narrative = switch (crisis.type) {
      RehearsalCrisisType.centerConflict => (
          isEn
              ? '${secondary!.name} refuses to back down.'
              : '${secondary!.name} geri çekilmek istemiyor.',
          isEn
              ? '${primary.name} was chosen as center, but ${secondary.name} believes the role belongs to her.'
              : '${primary.name} center seçildi ama ${secondary.name} bu rolün kendisine daha uygun olduğunu düşünüyor.',
        ),
      RehearsalCrisisType.vocalConflict => (
          isEn
              ? 'Two powerhouse voices, one massive climax.'
              : 'İki güçlü ses, tek büyük bölüm.',
          isEn
              ? '${primary.name} was named lead vocal. ${secondary!.name} feels confident tackling the climactic note.'
              : '${primary.name} ana vokal seçildi. ${secondary!.name} kritik yüksek notada kendine güveniyor.',
        ),
      RehearsalCrisisType.danceConflict => (
          isEn
              ? 'As the tempo rises, the rehearsal splinters.'
              : 'Tempo yükseldikçe prova bölünüyor.',
          isEn
              ? '${primary.name} wants crystal-clean formations. ${secondary!.name} demands more expressive freedom.'
              : '${primary.name} koreografinin temiz kalmasını istiyor. ${secondary!.name} daha fazla özgürlük arıyor.',
        ),
      RehearsalCrisisType.lastPickPressure => (
          isEn
              ? '${primary.name} is burning herself out in rehearsal.'
              : '${primary.name} provada fazla yükleniyor.',
          isEn
              ? 'Drafted last in team selection lit a fire, but fear of making mistakes is creeping in.'
              : 'Takım seçiminde en son seçilmesi onu motive etti ama hata yapmaktan korkmaya başladı.',
        ),
      RehearsalCrisisType.positiveDevelopment => (
          crisis.localizedHeadline(context),
          crisis.localizedDescription(context),
        ),
      RehearsalCrisisType.generic => (
          crisis.localizedHeadline(context),
          crisis.localizedDescription(context),
        ),
    };
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
              '${Localizations.localeOf(context).languageCode == "en" ? "TEAM" : "TAKIM"} ${captain.displayName}',
              style: _pinkLabel(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: people
                  .map(
                    (id) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: AspectRatio(
                          aspectRatio: .78,
                          child: ContestantPortrait(contestant: contestant(id)),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              crisis.localizedTitle(context),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(narrative.$1, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              narrative.$2,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.paperMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: isEn ? 'ENTER THIS REHEARSAL' : 'BU PROVAYA GİR',
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalMetricCard extends StatelessWidget {
  const _FinalMetricCard({
    required this.captain,
    required this.metrics,
    required this.badge,
    required this.narrative,
  });
  final Contestant captain;
  final RehearsalMetrics metrics;
  final String badge;
  final String narrative;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(badge, style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.md),
          _MetricBar(isEn ? 'CHEMISTRY' : 'UYUM', metrics.harmony),
          _MetricBar(isEn ? 'READINESS' : 'HAZIRLIK', metrics.readiness),
          _MetricBar(isEn ? 'ENERGY' : 'ENERJİ', metrics.energy),
          const Divider(color: AppColors.line),
          Row(
            children: [
              Expanded(
                child: Text(
                  isEn ? 'REHEARSAL STATUS' : 'PROVA DURUMU',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Text(
                '${metrics.score}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.accentBright),
              ),
            ],
          ),
          Text(
            rehearsalLabel(metrics.score, context),
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '“$narrative”',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
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

TextStyle? _pinkLabel(BuildContext context) => Theme.of(context)
    .textTheme
    .labelMedium
    ?.copyWith(color: AppColors.accentSoft, letterSpacing: .8);
