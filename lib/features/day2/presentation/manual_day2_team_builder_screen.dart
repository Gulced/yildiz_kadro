import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/day2/data/day2_team_compatibility.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_rehearsal_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_team_draft.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_draft_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_rehearsal.dart';
import 'package:yildiz_kadro/features/group_task/presentation/group_task_rehearsal_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';
import 'package:yildiz_kadro/shared/widgets/tv_components.dart';

enum _BuilderPhase { teams, rolesA, rolesB, review }

class ManualDay2TeamBuilderScreen extends StatefulWidget {
  const ManualDay2TeamBuilderScreen({
    required this.captainAId,
    required this.captainBId,
    super.key,
  });
  final int captainAId;
  final int captainBId;
  @override
  State<ManualDay2TeamBuilderScreen> createState() =>
      _ManualDay2TeamBuilderScreenState();
}

class _ManualDay2TeamBuilderScreenState
    extends State<ManualDay2TeamBuilderScreen> {
  _BuilderPhase phase = _BuilderPhase.teams;
  late final List<int> teamA = [widget.captainAId];
  late final List<int> teamB = [widget.captainBId];
  final rolesA = <String, int>{};
  final rolesB = <String, int>{};
  final assignmentOrder = <int>[];
  int? tapSelectedContestantId;

  Contestant c(int id) =>
      contestantSeedData.firstWhere((value) => value.id == id);
  List<int> get activeIds {
    final eliminated = GameScope.of(context).eliminatedContestantIds;
    return contestantSeedData
        .where((value) => !eliminated.contains(value.id))
        .map((value) => value.id)
        .toList();
  }

  List<int> get unassigned => activeIds
      .where((id) => !teamA.contains(id) && !teamB.contains(id))
      .toList();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        bottomNavigationBar: tapSelectedContestantId == null ||
                (phase != _BuilderPhase.rolesA && phase != _BuilderPhase.rolesB)
            ? null
            : _selectedMemberBar(tapSelectedContestantId!),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: switch (phase) {
              _BuilderPhase.teams => teamsPage(),
              _BuilderPhase.rolesA => rolesPage('A', teamA, rolesA),
              _BuilderPhase.rolesB => rolesPage('B', teamB, rolesB),
              _BuilderPhase.review => reviewPage(),
            },
          ),
        ),
      );

  Widget _selectedMemberBar(int id) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.accentInk,
            border: Border(top: BorderSide(color: AppColors.accentBright)),
          ),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: ContestantPortrait(contestant: c(id)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isEn = isAppEnglish(context);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn
                              ? '${c(id).displayName} SELECTED'
                              : '${c(id).displayName} SEÇİLDİ',
                          style: accent(),
                        ),
                        Text(
                          isEn
                              ? 'Vocal ${c(id).vocal} · Dance ${c(id).dance} · Stage ${c(id).stage}'
                              : 'Vokal ${c(id).vocal} · Dans ${c(id).dance} · Sahne ${c(id).stage}',
                        ),
                        Text(isEn ? 'Pick a role' : 'Bir rol seç'),
                      ],
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () => setState(() => tapSelectedContestantId = null),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      );

  Widget teamsPage() {
    final isEn = isAppEnglish(context);
    return page([
      Text(
        isEn ? 'BUILD THE TEAMS' : 'TAKIMLARI SEN KUR',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? 'Captains are ready. Distribute the remaining 12 contestants between both squads.'
            : 'Kaptanlar hazır. Kalan 12 yarışmacıyı iki takıma dağıt.',
      ),
      const SizedBox(height: AppSpacing.lg),
      teamStrip('A', teamA),
      const SizedBox(height: AppSpacing.md),
      teamStrip('B', teamB),
      const SizedBox(height: AppSpacing.xl),
      Text(
        isEn
            ? 'REMAINING CONTESTANTS — ${unassigned.length}'
            : 'KALAN YARIŞMACILAR — ${unassigned.length}',
        style: accent(),
      ),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: unassigned.map((id) {
          return InkWell(
            onTap: () => noteAndAssign(id),
            child: SizedBox(
              width: 105,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: .75,
                    child: ContestantPortrait(contestant: c(id)),
                  ),
                  Text(
                    c(id).displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isAppEnglish(context) ? 'ASSIGN ROLES' : 'ROLLERİ DAĞIT',
        onPressed: teamA.length == 7 && teamB.length == 7
            ? () => setState(() => phase = _BuilderPhase.rolesA)
            : null,
      ),
    ]);
  }

  Widget teamStrip(String id, List<int> members) {
    final state = GameScope.of(context);
    final averages = calculateTeamAverages(members, state.evaluation1Results);
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
            '${isEn ? "TEAM" : "TAKIM"} ${c(members.first).displayName} — ${members.length} / 7',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Wrap(
            spacing: 5,
            children: members.map((member) {
              return InkWell(
                onTap: member == members.first
                    ? null
                    : () => setState(() {
                          members.remove(member);
                          assignmentOrder.remove(member);
                        }),
                child: SizedBox(
                  width: 48,
                  child: Column(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: ContestantPortrait(contestant: c(member)),
                        ),
                      ),
                      Text(
                        c(member).displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${isEn ? "VOCAL" : "VOKAL"} ${averages.vocal.round()}  •  ${isEn ? "DANCE" : "DANS"} ${averages.dance.round()}  •  ${isEn ? "STAGE" : "SAHNE"} ${averages.stage.round()}  •  ${teamProfileLabel(averages, context)}',
            style: accent(),
          ),
          Text(
            '${isEn ? "CHEMISTRY" : "UYUM"} — ${harmonyLabel(members, context)}',
          ),
        ],
      ),
    );
  }

  Future<void> noteAndAssign(int id) async {
    final results = GameScope.of(context).evaluation1Results;
    final reportA = evaluateCandidateForTeam(
      candidateId: id,
      currentTeamIds: teamA,
      results: results,
    );
    final reportB = evaluateCandidateForTeam(
      candidateId: id,
      currentTeamIds: teamB,
      results: results,
    );
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      isScrollControlled: true,
      builder: (context) {
        final isEn = isAppEnglish(context);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c(id).displayName} • ${isEn ? "TEAM BRIEF" : "TAKIM NOTU"}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                candidateReport(
                  '${isEn ? "TEAM" : "TAKIM"} ${c(widget.captainAId).displayName}',
                  reportA,
                  context,
                ),
                const SizedBox(height: AppSpacing.lg),
                candidateReport(
                  '${isEn ? "TEAM" : "TAKIM"} ${c(widget.captainBId).displayName}',
                  reportB,
                  context,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: teamA.length < 7
                            ? () => Navigator.pop(context, 'A')
                            : null,
                        child: Text(
                          '${isEn ? "TEAM" : "TAKIM"} ${c(widget.captainAId).displayName}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: teamB.length < 7
                            ? () => Navigator.pop(context, 'B')
                            : null,
                        child: Text(
                          '${isEn ? "TEAM" : "TAKIM"} ${c(widget.captainBId).displayName}',
                        ),
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
    if (choice == null || !mounted) return;
    setState(() {
      (choice == 'A' ? teamA : teamB).add(id);
      assignmentOrder.add(id);
    });
  }

  Widget candidateReport(
    String title,
    CandidateTeamEvaluation report,
    BuildContext context,
  ) {
    return _CandidateAnalysisBox(
      title: title,
      report: report,
      c: c,
    );
  }

  Widget rolesPage(String teamId, List<int> members, Map<String, int> roles) {
    final slots = getRolesForTeamSize(members.length);
    final isEn = isAppEnglish(context);
    return page([
      Text(
        '${isEn ? "TEAM" : "TAKIM"} ${c(members.first).displayName}',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(isEn ? 'ASSIGN ROLES' : 'ROLLERİ DAĞIT', style: accent()),
      Text(
        isEn
            ? 'Select a contestant, then designate their role.'
            : 'Yarışmacıyı seç, ardından rolünü belirle.',
      ),
      Text(
        isEn
            ? 'You can also drag and drop cards directly into role slots.'
            : 'Kartı doğrudan role sürükleyerek de atayabilirsin.',
      ),
      const SizedBox(height: AppSpacing.lg),
      ...slots.map((slot) {
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) =>
              !roles.values.contains(details.data) ||
              roles[slot.id] == details.data,
          onAcceptWithDetails: (details) =>
              assignRole(roles, slot.id, details.data),
          builder: (context, candidates, rejected) {
            final id = roles[slot.id];
            return InkWell(
              onTap: () => setState(() {
                if (tapSelectedContestantId != null) {
                  assignRoleValue(roles, slot.id, tapSelectedContestantId!);
                  tapSelectedContestantId = null;
                } else if (id != null) {
                  roles.remove(slot.id);
                }
              }),
              child: Container(
                height: 92,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: candidates.isNotEmpty
                      ? AppColors.accentInk
                      : AppColors.inkSoft,
                  border: Border.all(
                    color: id == null ? AppColors.line : AppColors.accentBright,
                  ),
                ),
                child: Row(
                  children: [
                    if (id != null)
                      SizedBox(
                        width: 60,
                        child: ContestantPortrait(contestant: c(id)),
                      )
                    else
                      const SizedBox(width: 60, child: Icon(Icons.add_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day2TeamRoleLabel(slot.type, context),
                            style: accent(),
                          ),
                          Text(
                            id == null
                                ? (isEn
                                    ? 'Drop contestant here'
                                    : 'Yarışmacı bırak')
                                : c(id).displayName,
                          ),
                          Text(
                            tapSelectedContestantId == null
                                ? day2TeamRoleDescription(slot.type, context)
                                : roleSuitabilityFor(
                                    c(tapSelectedContestantId!),
                                    day2TeamRoleLabel(slot.type, context),
                                    context,
                                  ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      const SizedBox(height: AppSpacing.md),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: members.map((id) {
          final currentSlot = roles.entries
              .where((entry) => entry.value == id)
              .map((entry) => slots.firstWhere((slot) => slot.id == entry.key));
          return LongPressDraggable<int>(
            data: id,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 82,
                height: 100,
                child: ContestantPortrait(contestant: c(id)),
              ),
            ),
            child: InkWell(
              onTap: () => setState(
                () => tapSelectedContestantId =
                    tapSelectedContestantId == id ? null : id,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 96,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: tapSelectedContestantId == id
                        ? AppColors.accentBright
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: .78,
                      child: ContestantPortrait(contestant: c(id)),
                    ),
                    Text(c(id).displayName, maxLines: 1),
                    if (currentSlot.isNotEmpty)
                      Text(
                        day2TeamRoleLabel(currentSlot.first.type, context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: accent(),
                      ),
                    Text(
                      'V ${c(id).vocal} • D ${c(id).dance} • S ${c(id).stage}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: teamId == 'A'
            ? (isEn ? 'TEAM B ROLES' : 'TAKIM B ROLLERİ')
            : (isEn ? 'REVIEW SQUAD' : 'KADROYU İNCELE'),
        onPressed: roles.length == members.length
            ? () => setState(() {
                  tapSelectedContestantId = null;
                  phase = teamId == 'A'
                      ? _BuilderPhase.rolesB
                      : _BuilderPhase.review;
                })
            : null,
      ),
    ]);
  }

  void assignRole(Map<String, int> roles, String role, int id) => setState(() {
        assignRoleValue(roles, role, id);
      });
  void assignRoleValue(Map<String, int> roles, String role, int id) {
    roles.removeWhere((key, value) => value == id);
    roles[role] = id;
  }

  Widget reviewPage() {
    final isEn = isAppEnglish(context);
    final captainA = c(widget.captainAId);
    final captainB = c(widget.captainBId);
    final results = GameScope.of(context).evaluation1Results;
    final avgA = calculateTeamAverages(teamA, results);
    final avgB = calculateTeamAverages(teamB, results);

    return page([
      TvSectionHeader(
        eyebrow:
            isEn ? '2ND STAGE • TEAMS ASSEMBLED' : '2. GÜN • TAKIMLAR HAZIR',
        title: isEn ? 'TEAMS ASSEMBLED' : 'TAKIMLAR HAZIR',
        subtitle: isEn
            ? '14 Contestants · 2 Teams · One Stage'
            : '14 Yarışmacı · 2 Takım · Tek Sahne',
      ),
      const SizedBox(height: AppSpacing.md),
      _TeamRevealCard(
        teamLetter: 'A',
        captain: captainA,
        memberIds: teamA,
        roles: rolesA,
        averages: avgA,
        c: c,
      ),
      const SizedBox(height: AppSpacing.sm),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentInk,
            border: Border.all(color: AppColors.accentBright),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'VS',
            style: TextStyle(
              color: AppColors.accentBright,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      _TeamRevealCard(
        teamLetter: 'B',
        captain: captainB,
        memberIds: teamB,
        roles: rolesB,
        averages: avgB,
        c: c,
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'START REHEARSAL →' : 'PROVAYA BAŞLA →',
        onPressed: complete,
      ),
    ]);
  }

  Widget roleSummary(List<int> members, Map<String, int> roles) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          '${c(members.first).displayName}: ${getRolesForTeamSize(members.length).map((slot) => '${day2TeamRoleLabel(slot.type, context)} — ${c(roles[slot.id]!).displayName}').join('  •  ')}',
        ),
      );

  void complete() {
    final state = GameScope.of(context), events = <Day2DraftEvent>[];
    for (var i = 0; i < assignmentOrder.length; i++) {
      final id = assignmentOrder[i], inA = teamA.contains(id);
      events.add(
        Day2DraftEvent(
          captainId: inA ? widget.captainAId : widget.captainBId,
          selectedContestantId: id,
          pickNumber: i + 1,
          teamId: inA ? 'A' : 'B',
          reason: 'Producer squad assignment.',
        ),
      );
    }
    final result = Day2DraftResult(
      captainAId: widget.captainAId,
      captainBId: widget.captainBId,
      teamAIds: List.unmodifiable(teamA),
      teamBIds: List.unmodifiable(teamB),
      events: List.unmodifiable(events),
      lastPickedContestantId: assignmentOrder.last,
      teamAAverages: calculateTeamAverages(teamA, state.evaluation1Results),
      teamBAverages: calculateTeamAverages(teamB, state.evaluation1Results),
    );
    state.completeDay2TeamFormation(result);
    final setup = initializeDay2Rehearsal(
      teamAIds: teamA,
      teamBIds: teamB,
      captainAId: widget.captainAId,
      captainBId: widget.captainBId,
      lastPickedContestantId: assignmentOrder.last,
      evaluationResults: state.evaluation1Results,
      teamARoles: toAssignments(teamA, rolesA),
      teamBRoles: toAssignments(teamB, rolesB),
    );
    state.initializeDay2Rehearsal(setup);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const GroupTaskRehearsalScreen()),
    );
  }

  TeamRoleAssignments toAssignments(List<int> members, Map<String, int> roles) {
    final slots = getRolesForTeamSize(members.length);
    int memberFor(Day2TeamRoleType type) =>
        roles[slots.firstWhere((slot) => slot.type == type).id]!;
    return TeamRoleAssignments(
      centerId: memberFor(Day2TeamRoleType.center),
      mainVocalId: memberFor(Day2TeamRoleType.leadVocal),
      danceLeadId: memberFor(Day2TeamRoleType.leadDancer),
      groupMemberIds: List.unmodifiable(
        members.where(
          (id) => !{
            memberFor(Day2TeamRoleType.center),
            memberFor(Day2TeamRoleType.leadVocal),
            memberFor(Day2TeamRoleType.leadDancer),
          }.contains(id),
        ),
      ),
      roleSlots: List.unmodifiable(
        slots.map((slot) => (slot: slot, contestantId: roles[slot.id]!)),
      ),
    );
  }

  Widget page(List<Widget> children) => SingleChildScrollView(
        key: ValueKey(phase),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: MaxWidthContainer(
          maxWidth: 850,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
  TextStyle accent() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1);
  String harmonyLabel(List<int> ids, [BuildContext? context]) {
    final isEn = isAppEnglish(context);
    final styles =
        ids.map((id) => groupTaskProfiles[id]!.workStyle).toSet().length;
    if (isEn) {
      return styles >= 5
          ? 'STRONG'
          : styles >= 3
              ? 'BALANCED'
              : 'RISKY';
    }
    return styles >= 5
        ? 'GÜÇLÜ'
        : styles >= 3
            ? 'DENGELİ'
            : 'RİSKLİ';
  }
}

class _CandidateAnalysisBox extends StatefulWidget {
  const _CandidateAnalysisBox({
    required this.title,
    required this.report,
    required this.c,
  });

  final String title;
  final CandidateTeamEvaluation report;
  final Contestant Function(int) c;

  @override
  State<_CandidateAnalysisBox> createState() => _CandidateAnalysisBoxState();
}

class _CandidateAnalysisBoxState extends State<_CandidateAnalysisBox> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final report = widget.report;
    final strengths = report.localizedStrengths(context);
    final concerns = report.localizedConcerns(context);
    final topStrength = strengths.isNotEmpty
        ? strengths.first
        : (isEn ? 'Consistent team presence' : 'Dengeli takım varlığı');
    final topConcern = concerns.isNotEmpty
        ? concerns.first
        : (isEn ? 'No immediate conflict noted' : 'Belirgin bir çatışma yok');
    final pairCount = report.relationshipNotes.length;
    final riskCount = concerns.length;
    final balancedCount = (pairCount - riskCount).clamp(0, pairCount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TvBadge(
                label: '${isEn ? "CHEMISTRY" : "UYUM"} ${report.compatibility}',
                isAccent: true,
              ),
              const SizedBox(width: 6),
              TvBadge(
                label: '${isEn ? "RISK" : "RİSK"} ${report.risk}',
                color:
                    report.risk > 50 ? const Color(0xFF381219) : AppColors.ink,
                borderColor:
                    report.risk > 50 ? const Color(0xFFFF526E) : AppColors.line,
                textColor: report.risk > 50
                    ? const Color(0xFFFF526E)
                    : AppColors.paperMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2919),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  isEn ? 'STRENGTH' : 'GÜÇLÜ',
                  style: const TextStyle(
                    color: Color(0xFF4EFA9A),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topStrength,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF330E17),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  isEn ? 'RISK' : 'RİSK',
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  topConcern,
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                isEn ? 'TEAM DYNAMICS: ' : 'TAKIM DİNAMİĞİ: ',
                style: const TextStyle(
                  color: AppColors.paperMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                isEn
                    ? '$balancedCount balanced · $riskCount competitive'
                    : '$balancedCount dengeli eşleşme · $riskCount rekabet',
                style: const TextStyle(
                  color: AppColors.paper,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded
                        ? (isEn ? 'HIDE DETAILS ▲' : 'DETAYLARI GİZLE ▲')
                        : (isEn ? 'SEE DETAILS ▼' : 'DETAYLARI GÖR ▼'),
                    style: const TextStyle(
                      color: AppColors.accentBright,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 6),
            const Divider(color: AppColors.line, height: 1),
            const SizedBox(height: 6),
            ...report.localizedRelationshipNotes(context).entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      isEn
                          ? '• WITH ${widget.c(entry.key).displayName}: ${entry.value}'
                          : '• ${widget.c(entry.key).displayName} İLE: ${entry.value}',
                      style: const TextStyle(
                        color: AppColors.paperMuted,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _TeamRevealCard extends StatelessWidget {
  const _TeamRevealCard({
    required this.teamLetter,
    required this.captain,
    required this.memberIds,
    required this.roles,
    required this.averages,
    required this.c,
  });

  final String teamLetter;
  final Contestant captain;
  final List<int> memberIds;
  final Map<String, int> roles;
  final TeamAverages averages;
  final Contestant Function(int) c;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final slots = getRolesForTeamSize(memberIds.length);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 50,
                  height: 62,
                  child: ContestantPortrait(contestant: captain),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
                          style: const TextStyle(
                            color: AppColors.paper,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        TvBadge(
                          label: isEn ? 'CAPTAIN' : 'KAPTAN',
                          isAccent: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      teamProfileLabel(averages, context),
                      style: const TextStyle(
                        color: AppColors.accentBright,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TvScoreMeter(
                  label: context.l10n.vocal,
                  score: averages.vocal.round(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TvScoreMeter(
                  label: context.l10n.dance,
                  score: averages.dance.round(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TvScoreMeter(
                  label: context.l10n.stage,
                  score: averages.stage.round(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn ? 'LINEUP & ROLES' : 'KADRO VE ROLLER',
            style: const TextStyle(
              color: AppColors.paperMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: memberIds.map((id) {
              final slotMatch = roles.entries.where((e) => e.value == id);
              String? role;
              if (slotMatch.isNotEmpty) {
                final slot =
                    slots.firstWhere((s) => s.id == slotMatch.first.key);
                role = day2TeamRoleLabel(slot.type, context);
              }
              return TvContestantChip(
                contestant: c(id),
                roleLabel: role,
                isCaptain: id == captain.id,
                isCompact: true,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
