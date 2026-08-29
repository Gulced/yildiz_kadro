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

enum _BuilderPhase { teams, rolesA, rolesB, review }

class ManualDay2TeamBuilderScreen extends StatefulWidget {
  const ManualDay2TeamBuilderScreen(
      {required this.captainAId, required this.captainBId, super.key});
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
                _BuilderPhase.review => reviewPage()
              })));

  Widget _selectedMemberBar(int id) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.accentInk,
            border: Border(top: BorderSide(color: AppColors.accentBright)),
          ),
          child: Row(children: [
            ClipOval(
              child: SizedBox(
                width: 46,
                height: 46,
                child: ContestantPortrait(contestant: c(id)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${c(id).displayName} SEÇİLDİ', style: accent()),
                  Text(
                      'Vokal ${c(id).vocal} · Dans ${c(id).dance} · Sahne ${c(id).stage}'),
                  const Text('Bir rol seç'),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => tapSelectedContestantId = null),
              icon: const Icon(Icons.close_rounded),
            ),
          ]),
        ),
      );

  Widget teamsPage() => page([
        Text('TAKIMLARI SEN KUR',
            style: Theme.of(context).textTheme.displayLarge),
        const Text('Kaptanlar hazır. Kalan 12 yarışmacıyı iki takıma dağıt.'),
        const SizedBox(height: AppSpacing.lg),
        teamStrip('A', teamA),
        const SizedBox(height: AppSpacing.md),
        teamStrip('B', teamB),
        const SizedBox(height: AppSpacing.xl),
        Text('KALAN YARIŞMACILAR — ${unassigned.length}', style: accent()),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: unassigned.map((id) {
            return InkWell(
              onTap: () => noteAndAssign(id),
              child: SizedBox(
                width: 105,
                child: Column(children: [
                  AspectRatio(
                    aspectRatio: .75,
                    child: ContestantPortrait(contestant: c(id)),
                  ),
                  Text(c(id).displayName,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'ROLLERİ DAĞIT',
          onPressed: teamA.length == 7 && teamB.length == 7
              ? () => setState(() => phase = _BuilderPhase.rolesA)
              : null,
        ),
      ]);

  Widget teamStrip(String id, List<int> members) {
    final state = GameScope.of(context);
    final averages = calculateTeamAverages(members, state.evaluation1Results);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TAKIM ${c(members.first).displayName} — ${members.length} / 7',
            style: Theme.of(context).textTheme.headlineSmall),
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
                child: Column(children: [
                  ClipOval(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: ContestantPortrait(contestant: c(member)),
                    ),
                  ),
                  Text(c(member).displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'VOKAL ${averages.vocal.round()}  •  DANS ${averages.dance.round()}  •  SAHNE ${averages.stage.round()}  •  ${teamProfileLabel(averages)}',
          style: accent(),
        ),
        Text('UYUM — ${harmonyLabel(members)}'),
      ]),
    );
  }

  Future<void> noteAndAssign(int id) async {
    final results = GameScope.of(context).evaluation1Results;
    final reportA = evaluateCandidateForTeam(
        candidateId: id, currentTeamIds: teamA, results: results);
    final reportB = evaluateCandidateForTeam(
        candidateId: id, currentTeamIds: teamB, results: results);
    final choice = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: AppColors.inkSoft,
        isScrollControlled: true,
        builder: (context) => SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c(id).displayName} • TAKIM NOTU',
                          style: Theme.of(context).textTheme.headlineLarge),
                      candidateReport(
                          'TAKIM ${c(widget.captainAId).displayName}', reportA),
                      const SizedBox(height: AppSpacing.lg),
                      candidateReport(
                          'TAKIM ${c(widget.captainBId).displayName}', reportB),
                      const SizedBox(height: AppSpacing.lg),
                      Row(children: [
                        Expanded(
                            child: FilledButton(
                                onPressed: teamA.length < 7
                                    ? () => Navigator.pop(context, 'A')
                                    : null,
                                child: Text(
                                    'TAKIM ${c(widget.captainAId).displayName}'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: FilledButton(
                                onPressed: teamB.length < 7
                                    ? () => Navigator.pop(context, 'B')
                                    : null,
                                child: Text(
                                    'TAKIM ${c(widget.captainBId).displayName}')))
                      ])
                    ]))));
    if (choice == null || !mounted) return;
    setState(() {
      (choice == 'A' ? teamA : teamB).add(id);
      assignmentOrder.add(id);
    });
  }

  Widget candidateReport(String title, CandidateTeamEvaluation report) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
            color: AppColors.ink, border: Border.all(color: AppColors.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text('UYUM ${report.compatibility}  •  RİSK ${report.risk}',
              style: accent()),
          const SizedBox(height: AppSpacing.sm),
          Text('GÜÇLÜ YÖNLER', style: accent()),
          Text(report.strengths.map((text) => '• $text').join('\n')),
          const SizedBox(height: AppSpacing.sm),
          Text('DİKKAT EDİLECEKLER', style: accent()),
          Text(report.concerns.map((text) => '• $text').join('\n')),
          const SizedBox(height: AppSpacing.sm),
          ...report.relationshipNotes.entries.map((entry) => Text(
              '${c(entry.key).displayName} İLE — ${entry.value}',
              style: Theme.of(context).textTheme.bodySmall)),
        ]),
      );

  Widget rolesPage(String teamId, List<int> members, Map<String, int> roles) {
    final slots = getRolesForTeamSize(members.length);
    return page([
      Text('TAKIM ${c(members.first).displayName}',
          style: Theme.of(context).textTheme.displayLarge),
      Text('ROLLERİ DAĞIT', style: accent()),
      const Text('Yarışmacıyı seç, ardından rolünü belirle.'),
      const Text('Kartı doğrudan role sürükleyerek de atayabilirsin.'),
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
                      color:
                          id == null ? AppColors.line : AppColors.accentBright),
                ),
                child: Row(children: [
                  if (id != null)
                    SizedBox(
                        width: 60, child: ContestantPortrait(contestant: c(id)))
                  else
                    const SizedBox(width: 60, child: Icon(Icons.add_rounded)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(day2TeamRoleLabel(slot.type), style: accent()),
                        Text(
                            id == null ? 'Yarışmacı bırak' : c(id).displayName),
                        Text(
                            tapSelectedContestantId == null
                                ? day2TeamRoleDescription(slot.type)
                                : roleSuitabilityFor(
                                    c(tapSelectedContestantId!),
                                    day2TeamRoleLabel(slot.type)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ]),
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
                  child: ContestantPortrait(contestant: c(id))),
            ),
            child: InkWell(
              onTap: () => setState(() => tapSelectedContestantId =
                  tapSelectedContestantId == id ? null : id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 96,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: tapSelectedContestantId == id
                            ? AppColors.accentBright
                            : Colors.transparent)),
                child: Column(children: [
                  AspectRatio(
                      aspectRatio: .78,
                      child: ContestantPortrait(contestant: c(id))),
                  Text(c(id).displayName, maxLines: 1),
                  if (currentSlot.isNotEmpty)
                    Text(day2TeamRoleLabel(currentSlot.first.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: accent()),
                  Text('V ${c(id).vocal} • D ${c(id).dance} • S ${c(id).stage}',
                      style: Theme.of(context).textTheme.labelSmall),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: teamId == 'A' ? 'TAKIM B ROLLERİ' : 'KADROYU İNCELE',
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

  Widget reviewPage() => page([
        Text('TAKIMLAR HAZIR', style: Theme.of(context).textTheme.displayLarge),
        teamStrip('A', teamA),
        const SizedBox(height: 10),
        teamStrip('B', teamB),
        const SizedBox(height: AppSpacing.lg),
        roleSummary(teamA, rolesA),
        roleSummary(teamB, rolesB),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'İKİ TAKIMIN PROVASINA GİR', onPressed: complete)
      ]);
  Widget roleSummary(List<int> members, Map<String, int> roles) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
          '${c(members.first).displayName}: ${getRolesForTeamSize(members.length).map((slot) => '${day2TeamRoleLabel(slot.type)} — ${c(roles[slot.id]!).displayName}').join('  •  ')}'));

  void complete() {
    final state = GameScope.of(context), events = <Day2DraftEvent>[];
    for (var i = 0; i < assignmentOrder.length; i++) {
      final id = assignmentOrder[i], inA = teamA.contains(id);
      events.add(Day2DraftEvent(
          captainId: inA ? widget.captainAId : widget.captainBId,
          selectedContestantId: id,
          pickNumber: i + 1,
          teamId: inA ? 'A' : 'B',
          reason: 'Oyuncu takım dağılımı.'));
    }
    final result = Day2DraftResult(
        captainAId: widget.captainAId,
        captainBId: widget.captainBId,
        teamAIds: List.unmodifiable(teamA),
        teamBIds: List.unmodifiable(teamB),
        events: List.unmodifiable(events),
        lastPickedContestantId: assignmentOrder.last,
        teamAAverages: calculateTeamAverages(teamA, state.evaluation1Results),
        teamBAverages: calculateTeamAverages(teamB, state.evaluation1Results));
    state.completeDay2TeamFormation(result);
    final setup = initializeDay2Rehearsal(
        teamAIds: teamA,
        teamBIds: teamB,
        captainAId: widget.captainAId,
        captainBId: widget.captainBId,
        lastPickedContestantId: assignmentOrder.last,
        evaluationResults: state.evaluation1Results,
        teamARoles: toAssignments(teamA, rolesA),
        teamBRoles: toAssignments(teamB, rolesB));
    state.initializeDay2Rehearsal(setup);
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => const GroupTaskRehearsalScreen()));
  }

  TeamRoleAssignments toAssignments(List<int> members, Map<String, int> roles) {
    final slots = getRolesForTeamSize(members.length);
    int memberFor(Day2TeamRoleType type) =>
        roles[slots.firstWhere((slot) => slot.type == type).id]!;
    return TeamRoleAssignments(
        centerId: memberFor(Day2TeamRoleType.center),
        mainVocalId: memberFor(Day2TeamRoleType.leadVocal),
        danceLeadId: memberFor(Day2TeamRoleType.leadDancer),
        groupMemberIds: List.unmodifiable(members.where((id) => !{
              memberFor(Day2TeamRoleType.center),
              memberFor(Day2TeamRoleType.leadVocal),
              memberFor(Day2TeamRoleType.leadDancer)
            }.contains(id))),
        roleSlots: List.unmodifiable(
            slots.map((slot) => (slot: slot, contestantId: roles[slot.id]!))));
  }

  Widget page(List<Widget> children) => SingleChildScrollView(
      key: ValueKey(phase),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: MaxWidthContainer(
          maxWidth: 850,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children)));
  TextStyle accent() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1);
  String harmonyLabel(List<int> ids) {
    final styles =
        ids.map((id) => groupTaskProfiles[id]!.workStyle).toSet().length;
    return styles >= 5
        ? 'GÜÇLÜ'
        : styles >= 3
            ? 'DENGELİ'
            : 'RİSKLİ';
  }
}
