import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/postgame/data/final_group_customization_engine.dart';
import 'package:yildiz_kadro/features/postgame/domain/final_group_customization.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase { positions, leader, colors, review }

class FinalGroupCustomizationScreen extends StatefulWidget {
  const FinalGroupCustomizationScreen({super.key});

  @override
  State<FinalGroupCustomizationScreen> createState() =>
      _FinalGroupCustomizationScreenState();
}

class _FinalGroupCustomizationScreenState
    extends State<FinalGroupCustomizationScreen> {
  _Phase phase = _Phase.positions;
  final positions = <FinalMemberPosition, int>{};
  final colors = <int, MemberColor>{};
  int? leaderId;

  Contestant contestant(int id) =>
      contestantSeedData.firstWhere((value) => value.id == id);

  List<int> get ids => GameScope.of(context).playerFinalLineupIds;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: switch (phase) {
              _Phase.positions => _positionsPage(),
              _Phase.leader => _leaderPage(),
              _Phase.colors => _colorsPage(),
              _Phase.review => _reviewPage(),
            },
          ),
        ),
      );

  Widget _positionsPage() => _page([
        Text('GRUBUNU TAMAMLA',
            style: Theme.of(context).textTheme.displayLarge),
        const Text('Beş üyeye performans pozisyonlarını sen ver.'),
        const SizedBox(height: AppSpacing.lg),
        ...FinalMemberPosition.values.map(_positionTarget),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ids.map(_draggableMember).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'LİDERİ SEÇ',
          onPressed: positions.length == 5
              ? () => setState(() => phase = _Phase.leader)
              : null,
        ),
      ]);

  Widget _positionTarget(FinalMemberPosition position) => DragTarget<int>(
        onWillAcceptWithDetails: (details) =>
            !positions.values.contains(details.data) ||
            positions[position] == details.data,
        onAcceptWithDetails: (details) => _assign(position, details.data),
        builder: (context, candidates, rejected) {
          final id = positions[position];
          return InkWell(
            onTap: id == null
                ? null
                : () => setState(() => positions.remove(position)),
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
              child: Row(children: [
                SizedBox(
                  width: 62,
                  child: id == null
                      ? const Icon(Icons.star_border_rounded)
                      : ContestantPortrait(contestant: contestant(id)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(finalPositionLabel(position), style: _accent()),
                      Text(id == null
                          ? 'Üye bırak'
                          : contestant(id).displayName),
                      if (id != null)
                        Text(_fitText(position, id),
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      );

  Widget _draggableMember(int id) => LongPressDraggable<int>(
        data: id,
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 85,
            height: 105,
            child: ContestantPortrait(contestant: contestant(id)),
          ),
        ),
        child: InkWell(
          onTap: () => _pickPosition(id),
          child: SizedBox(
            width: 104,
            child: Column(children: [
              AspectRatio(
                aspectRatio: .75,
                child: ContestantPortrait(contestant: contestant(id)),
              ),
              Text(contestant(id).displayName, maxLines: 1),
            ]),
          ),
        ),
      );

  Widget _leaderPage() => _page([
        Text('GRUBUN LİDERİ KİM?',
            style: Theme.of(context).textTheme.displayLarge),
        const Text('Liderlik performans pozisyonlarından bağımsızdır.'),
        const SizedBox(height: AppSpacing.lg),
        ...ids.map((id) {
          return InkWell(
            onTap: () => setState(() => leaderId = id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.inkSoft,
                border: Border.all(
                  color:
                      leaderId == id ? AppColors.accentBright : AppColors.line,
                ),
              ),
              child: Row(children: [
                ClipOval(
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: ContestantPortrait(contestant: contestant(id)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contestant(id).displayName),
                      Text(
                        leadershipCommentFor(contestant(id)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          );
        }),
        AppButton(
          label: 'TEMSİL RENKLERİ',
          onPressed: leaderId == null
              ? null
              : () => setState(() => phase = _Phase.colors),
        ),
      ]);

  Widget _colorsPage() => _page([
        Text('TEMSİL RENKLERİ',
            style: Theme.of(context).textTheme.displayLarge),
        const Text('Her üyeye farklı bir renk seç.'),
        const SizedBox(height: AppSpacing.lg),
        ...ids.map((id) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    ClipOval(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: ContestantPortrait(contestant: contestant(id)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(contestant(id).displayName),
                    if (colors[id] != null)
                      Flexible(
                        child: Text('  •  ${memberColorLabel(colors[id]!)}',
                            style: _accent(), overflow: TextOverflow.ellipsis),
                      ),
                  ]),
                  Wrap(
                    spacing: 5,
                    children: MemberColor.values.map((color) {
                      final used = colors.entries.any(
                          (entry) => entry.key != id && entry.value == color);
                      return ChoiceChip(
                        label: Text(memberColorLabel(color)),
                        selected: colors[id] == color,
                        onSelected: used
                            ? null
                            : (_) => setState(() => colors[id] = color),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )),
        AppButton(
          label: 'GRUBU İNCELE',
          onPressed: colors.length == 5
              ? () => setState(() => phase = _Phase.review)
              : null,
        ),
      ]);

  Widget _reviewPage() {
    final tags = calculateAutomaticGroupTags(GameScope.of(context), positions);
    return _page([
      Text('YILDIZ KADRO HAZIR',
          style: Theme.of(context).textTheme.displayLarge),
      ...ids.map((id) {
        final position =
            positions.entries.firstWhere((entry) => entry.value == id).key;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipOval(
            child: SizedBox(
              width: 58,
              height: 58,
              child: ContestantPortrait(contestant: contestant(id)),
            ),
          ),
          title: Text(contestant(id).displayName),
          subtitle: Text(
            '${finalPositionLabel(position)}\n${tags[id]!.join(' · ')}',
          ),
          trailing: Text(memberColorLabel(colors[id]!), style: _accent()),
        );
      }),
      Text('LİDER — ${contestant(leaderId!).displayName}',
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: 'DEBUT KADROSUNU ONAYLA',
        onPressed: () {
          GameScope.of(context).completeFinalCustomization(
            positions: positions,
            leaderId: leaderId!,
            colors: colors,
            automaticTags: tags,
          );
          Navigator.pop(context, true);
        },
      ),
    ]);
  }

  void _assign(FinalMemberPosition position, int id) => setState(() {
        positions.removeWhere((key, value) => value == id);
        positions[position] = id;
      });

  Future<void> _pickPosition(int id) async {
    final value = await showModalBottomSheet<FinalMemberPosition>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FinalMemberPosition.values
              .map((position) => ListTile(
                    title: Text(finalPositionLabel(position)),
                    onTap: () => Navigator.pop(context, position),
                  ))
              .toList(),
        ),
      ),
    );
    if (value != null && mounted) _assign(value, id);
  }

  String _fitText(FinalMemberPosition position, int id) {
    final member = contestant(id);
    final score = switch (position) {
      FinalMemberPosition.mainVocal => member.vocal,
      FinalMemberPosition.leadVocal => (member.vocal + member.stage) ~/ 2,
      FinalMemberPosition.mainDancer => member.dance,
      FinalMemberPosition.leadDancer => (member.dance + member.stage) ~/ 2,
      FinalMemberPosition.rapper =>
        (member.dance + member.stage + member.popularity) ~/ 3,
    };
    return score >= 86
        ? 'Rol uyumu güçlü.'
        : score >= 78
            ? 'Rolü dengeli taşıyabilir.'
            : 'Bu pozisyonda daha fazla çalışma isteyecek.';
  }

  Widget _page(List<Widget> children) => SingleChildScrollView(
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

  TextStyle _accent() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright);
}
