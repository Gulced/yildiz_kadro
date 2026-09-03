import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day6_final_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/home/presentation/home_screen.dart';
import 'package:yildiz_kadro/features/postgame/domain/final_group_customization.dart';
import 'package:yildiz_kadro/features/postgame/presentation/widgets/debut_lineup_poster.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/contestant_dialogue_bubble.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class SeasonCompleteHubScreen extends StatelessWidget {
  const SeasonCompleteHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final validation = _validateSeason(state);
    if (!validation.isValid) {
      return _IncompleteSeasonScreen(message: validation.message);
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: MaxWidthContainer(
              maxWidth: 900,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DebutLineupPoster(memberIds: state.playerFinalLineupIds),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    isAppEnglish(context)
                        ? '${state.groupName!.toUpperCase()} IS READY'
                        : '${state.groupName!.toUpperCase()} HAZIR',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    isAppEnglish(context)
                        ? 'Started with 15. Taking the stage as 5.'
                        : '15 kişiyle başladı. 5 kişiyle sahneye çıkıyor.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    groupProfile(state.finalLineupBalance!, context),
                    style: _accent(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    isAppEnglish(context)
                        ? 'YOU BUILT THIS LINEUP'
                        : 'BU KADROYU SEN KURDUN',
                    style: _accent(context),
                  ),
                  Text(
                    isAppEnglish(context)
                        ? 'The competition carried them to the finale. You picked the final five.'
                        : 'Yarışma onları finale taşıdı. Son beşliyi sen seçtin.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _HubButton(
                    label: isAppEnglish(context) ? 'MY LINEUP' : 'KADROM',
                    subtitle: isAppEnglish(context)
                        ? 'Group profile and member roles'
                        : 'Grup profili ve roller',
                    onTap: () => _open(context, const _GroupProfileScreen()),
                  ),
                  _HubButton(
                    label: isAppEnglish(context) ? 'MY SEASON' : 'SEZONUM',
                    subtitle: isAppEnglish(context)
                        ? 'Decisions made across 6 days'
                        : '6 günde verdiğin kararlar',
                    onTap: () => _open(context, const _SeasonRecapScreen()),
                  ),
                  _HubButton(
                    label: isAppEnglish(context) ? 'THE JOURNEY' : 'YOLCULUK',
                    subtitle: isAppEnglish(context)
                        ? 'Season archive of all 15 talents'
                        : '15 yarışmacının sezon arşivi',
                    onTap: () => _open(context, const _SeasonJourneyScreen()),
                  ),
                  _HubButton(
                    label:
                        isAppEnglish(context) ? 'GROUP ARCHIVE' : 'GRUP ARŞİVİ',
                    subtitle: isAppEnglish(context)
                        ? 'Lineups from completed seasons'
                        : 'Tamamladığın sezonların kadroları',
                    onTap: () => _open(context, const _GroupArchiveScreen()),
                  ),
                  _HubButton(
                    label: isAppEnglish(context) ? 'NEW SEASON' : 'YENİ SEZON',
                    subtitle: isAppEnglish(context)
                        ? 'Who will you see differently this time?'
                        : 'Bu kez kimi farklı göreceksin?',
                    onTap: () => _confirmReset(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAppEnglish(context)
                    ? 'START A NEW SEASON?'
                    : 'YENİ SEZON BAŞLATILSIN MI?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                isAppEnglish(context)
                    ? 'Current season results will be reset.'
                    : 'Mevcut sezon sonuçların sıfırlanacak.',
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isAppEnglish(context) ? 'CANCEL' : 'VAZGEÇ'),
              ),
              AppButton(
                label: isAppEnglish(context)
                    ? 'START NEW SEASON'
                    : 'YENİ SEZON BAŞLAT',
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    GameScope.of(context).resetSeason();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const _NewSeasonTransition()),
      (_) => false,
    );
  }
}

class _NewSeasonTransition extends StatefulWidget {
  const _NewSeasonTransition();
  @override
  State<_NewSeasonTransition> createState() => _NewSeasonTransitionState();
}

class _NewSeasonTransitionState extends State<_NewSeasonTransition> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEn ? 'NEW SEASON' : 'YENİ SEZON'),
              const SizedBox(height: AppSpacing.md),
              Text(
                isEn
                    ? 'Who will you see differently this time?'
                    : 'Bu kez kimi farklı göreceksin?',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupProfileScreen extends StatelessWidget {
  const _GroupProfileScreen();
  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context), balance = state.finalLineupBalance!;
    final entries = {
      'VOKAL': balance.vocal,
      'DANS': balance.dance,
      'SAHNE': balance.stage,
      'KAMERA': balance.camera,
      'UYUM': balance.harmony,
    };
    final strongest = entries.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        ),
        developing = entries.entries.reduce(
          (a, b) => a.value <= b.value ? a : b,
        );
    final isEn = isAppEnglish(context);
    final localizedEntries = {
      isEn ? 'VOCALS' : 'VOKAL': balance.vocal,
      isEn ? 'DANCE' : 'DANS': balance.dance,
      isEn ? 'STAGE' : 'SAHNE': balance.stage,
      isEn ? 'CAMERA' : 'KAMERA': balance.camera,
      isEn ? 'HARMONY' : 'UYUM': balance.harmony,
    };
    return _PostgameScaffold(
      title: state.groupName!.toUpperCase(),
      children: [
        Text(
          groupProfile(balance, context),
          style: Theme.of(context).textTheme.displayLarge,
        ),
        DebutLineupPoster(memberIds: state.playerFinalLineupIds, height: 310),
        const SizedBox(height: AppSpacing.xl),
        ...localizedEntries.entries.map(
          (entry) => _EditorialMeter(label: entry.key, value: entry.value),
        ),
        const SizedBox(height: AppSpacing.xl),
        _InfoBlock(
          label: isEn ? 'GROUP SIGNATURE' : 'GRUBUN İMZASI',
          value: strongest.key,
          body: isEn
              ? '${strongest.key.toLowerCase()} power is this quintet’s defining trait.'
              : '${strongest.key.toLowerCase()} gücü bu beşlinin en belirgin ortak imzası.',
        ),
        _InfoBlock(
          label: isEn ? 'GROWTH AREA' : 'GELİŞTİRİLECEK ALAN',
          value: developing.key,
          body: isEn
              ? 'Will require extra rehearsal compared to their other disciplines.'
              : 'Grubun diğer alanlarına göre daha fazla birlikte çalışma isteyecek.',
        ),
        _InfoBlock(
          label: isEn ? 'GROUP CHEMISTRY' : 'GRUP KİMYASI',
          value: chemistry(balance.harmony, context),
          body: '',
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(isEn ? 'FINAL LINEUP' : 'KESİN KADRO', style: _accent(context)),
        ...FinalMemberPosition.values.map((role) {
          final id = state.finalMemberPositions[role]!;
          final color = state.finalMemberColors[id]!;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipOval(
              child: SizedBox(
                width: 48,
                height: 48,
                child: ContestantPortrait(contestant: _contestant(id)),
              ),
            ),
            title: Text(
              '${_contestant(id).displayName}${state.finalLeaderId == id ? (isEn ? "  •  LEADER" : "  •  LİDER") : ""}',
            ),
            subtitle: Text(
              '${finalPositionLabel(role)}  •  ${memberColorLabel(color, context)}',
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        Text(isEn ? 'GROUP TAGS' : 'GRUP ETİKETLERİ', style: _accent(context)),
        Text(
          state.automaticGroupTags.values
              .expand((tags) => tags)
              .toSet()
              .join('  •  '),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          isEn ? 'FIRST GROUP MOMENT' : 'İLK GRUP ANI',
          style: _accent(context),
        ),
        ..._groupDialogue(state, context).asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: ContestantDialogueBubble(
                  contestant: _contestant(entry.value.$1),
                  text: entry.value.$2,
                  alignRight: entry.key.isOdd,
                ),
              ),
            ),
      ],
    );
  }
}

class _GroupArchiveScreen extends StatelessWidget {
  const _GroupArchiveScreen();

  @override
  Widget build(BuildContext context) {
    final archive = GameScope.of(context).groupArchive.reversed.toList();
    final isEn = isAppEnglish(context);
    return _PostgameScaffold(
      title: isEn ? 'GROUP ARCHIVE' : 'GRUP ARŞİVİ',
      children: [
        if (archive.isEmpty)
          Text(
            isEn
                ? 'No completed seasons found yet.'
                : 'Henüz tamamlanmış bir sezon bulunmuyor.',
          ),
        ...archive.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.inkSoft,
                border: Border.all(color: AppColors.line),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.groupName.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      isEn
                          ? 'OVERALL SCORE  ${entry.overallScore}'
                          : 'GENEL PUAN  ${entry.overallScore}',
                      style: _accent(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DebutLineupPoster(memberIds: entry.memberIds, height: 220),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isEn
                          ? 'MOST POPULAR  ${_contestant(entry.mostPopularMemberId).displayName}'
                          : 'EN POPÜLER  ${_contestant(entry.mostPopularMemberId).displayName}',
                      style: _accent(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeasonRecapScreen extends StatelessWidget {
  const _SeasonRecapScreen();
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context),
        lineup = state.playerFinalLineupIds,
        radarCount =
            lineup.where(state.playerRadarContestantIds.contains).length,
        cards = <Widget>[];
    final impact = [
      state.day2DuelResultSnapshot?.playerChangedOutcome ?? false,
      state.day3FinalCutResultSnapshot?.playerChangedOutcome ?? false,
      state.day4ResultSnapshot?.playerChangedRoomElimination ?? false,
      state.day5ResultSnapshot?.playerChangedCut ?? false,
    ].where((value) => value).length;
    if (impact > 0) {
      cards.add(
        _RecapCard(
          title: isEn ? 'YOUR DECISIONS' : 'KARARLARIN',
          value: isEn
              ? 'Directly altered $impact critical elimination outcomes.'
              : '$impact kritik sonucu gerçekten değiştirdi.',
        ),
      );
    }
    cards.add(
      _RecapCard(
        title: isEn ? 'INITIAL RADAR' : 'İLK RADARIN',
        value: isEn
            ? 'Reached final lineup: $radarCount / 5\nLater discoveries: ${5 - radarCount} members'
            : 'Final kadrona giren: $radarCount / 5\nSonradan keşfettiğin: ${5 - radarCount} üye',
        portraits: state.playerRadarContestantIds,
      ),
    );
    final producer = state.producerSaveContestantId;
    if (producer != null && lineup.contains(producer)) {
      cards.add(
        _RecapCard(
          title: isEn ? 'SAVED ON DAY 1' : 'İLK GÜN KORUDUĞUN',
          value: isEn
              ? '${_contestant(producer).displayName} made it all the way to the debut lineup.'
              : '${_contestant(producer).displayName}, debut kadrosuna kadar geldi.',
          portraits: [producer],
        ),
      );
    }
    final coached = state.lastChanceCoachContestantId;
    if (coached != null && lineup.contains(coached)) {
      cards.add(
        _RecapCard(
          title: isEn ? 'BACKED IN LAST CHANCE' : "SON ŞANS'TA DESTEKLEDİĞİN",
          value: isEn
              ? '${_contestant(coached).displayName} is now in the Star Lineup.'
              : '${_contestant(coached).displayName} şimdi Yıldız Kadro’da.',
          portraits: [coached],
        ),
      );
    }
    final captains = [
      state.day2CaptainAId,
      state.day2CaptainBId,
    ].whereType<int>().where(lineup.contains).toList();
    if (captains.isNotEmpty) {
      cards.add(
        _RecapCard(
          title: isEn ? 'CAPTAIN PICKS' : 'KAPTAN SEÇİMİN',
          value: captains.length == 2
              ? (isEn
                  ? 'Both captains you chose made the Star Lineup.'
                  : 'Seçtiğin iki kaptan da Yıldız Kadro’da.')
              : (isEn
                  ? '${_contestant(captains.first).displayName} made your final lineup.'
                  : '${_contestant(captains.first).displayName} final kadrona girdi.'),
          portraits: captains,
        ),
      );
    }
    final directed = state
        .day3IdentitySetupSnapshot!.creativeDirectionByContestantId.keys
        .where(lineup.contains)
        .toList();
    if (directed.isNotEmpty) {
      cards.add(
        _RecapCard(
          title: isEn ? 'CREATIVE TOUCH' : 'YARATICI SÜRECİNE DOKUNDUĞUN',
          value: isEn
              ? '${directed.length} / 3 directed contestants in the final lineup.'
              : '${directed.length} / 3 yarışmacı final grubunda.',
          portraits: directed,
        ),
      );
    }
    final jury = lineup.where(state.recommendedFinalLineupIds.contains).length;
    cards.add(
      _RecapCard(
        title: isEn ? 'MATCHING JURY PICK' : 'JÜRİ ÖNERİSİYLE ORTAK',
        value: isEn
            ? '$jury / 5\n${jury == 5 ? "You picked the exact quintet recommended by the jury." : jury >= 3 ? "You aligned with the jury on key spots." : "You carved your own independent path for the final lineup."}'
            : '$jury / 5\n${jury == 5 ? "Jürinin önerdiği beşliyi aynen seçtin." : jury >= 3 ? "Bazı noktalarda jüriyle aynı düşündün." : "Final kadroda kendi yolunu seçtin."}',
      ),
    );
    final discovered = lineup
        .where((id) => !state.playerRadarContestantIds.contains(id))
        .toList()
      ..sort(
        (a, b) => state.day6ResultSnapshot!.results[b]!.growth.compareTo(
          state.day6ResultSnapshot!.results[a]!.growth,
        ),
      );
    if (discovered.isNotEmpty) {
      cards.insert(
        minOf(cards.length, 3),
        _RecapCard(
          title: isEn ? 'CHANGED YOUR MIND' : 'SENİ FİKRİNDEN DÖNDÜREN',
          value: isEn
              ? '${_contestant(discovered.first).displayName}\nWas not in your initial radar. Earned a spot in your final lineup.'
              : '${_contestant(discovered.first).displayName}\nİlk radarında değildi. Final kadrona girdi.',
          portraits: [discovered.first],
        ),
      );
    }
    return _PostgameScaffold(
      title: isEn ? 'WHAT CHANGED IN 6 DAYS?' : '6 GÜNDE NE DEĞİŞTİ?',
      children: cards.take(6).toList(),
    );
  }
}

class _SeasonJourneyScreen extends StatelessWidget {
  const _SeasonJourneyScreen();
  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final isEn = isAppEnglish(context);
    return _PostgameScaffold(
      title: isEn ? 'SEASON JOURNEY' : 'SEZON YOLCULUĞU',
      children: [
        _JourneySection(
          title: isEn ? 'STAR LINEUP — 5' : 'YILDIZ KADRO — 5',
          ids: state.playerFinalLineupIds,
          state: state,
          debut: true,
        ),
        _JourneySection(
          title: isEn ? 'FINALISTS — 2' : 'FİNALİST — 2',
          ids: state.finalistsOutsideDebutLineupIds,
          state: state,
          finalist: true,
        ),
        _JourneySection(
          title: isEn ? 'DEPARTED TALENTS — 8' : 'VEDA EDENLER — 8',
          ids: state.eliminatedContestantIds,
          state: state,
        ),
      ],
    );
  }
}

class _JourneySection extends StatelessWidget {
  const _JourneySection({
    required this.title,
    required this.ids,
    required this.state,
    this.debut = false,
    this.finalist = false,
  });
  final String title;
  final List<int> ids;
  final GameState state;
  final bool debut;
  final bool finalist;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: _accent(context)),
          ...ids.map(
            (id) => InkWell(
              onTap: () => _showHistory(context, id, state),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 58,
                        height: 58,
                        child: ContestantPortrait(contestant: _contestant(id)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_contestant(id).displayName),
                          Text(
                            debut
                                ? finalPositionLabel(
                                    state.finalMemberPositions.entries
                                        .firstWhere(
                                            (entry) => entry.value == id)
                                        .key,
                                  )
                                : finalist
                                    ? (isAppEnglish(context)
                                        ? 'FINALIST • Missed the debut lineup.'
                                        : 'FİNALİST • Debut kadrosuna giremedi.')
                                    : eliminationPoint(id, state, context),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}

class _PostgameScaffold extends StatelessWidget {
  const _PostgameScaffold({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: MaxWidthContainer(
              maxWidth: 850,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Text(title, style: _accent(context)),
                  const SizedBox(height: AppSpacing.lg),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      );
}

class _HubButton extends StatelessWidget {
  const _HubButton({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final String label, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      );
}

class _EditorialMeter extends StatelessWidget {
  const _EditorialMeter({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: _accent(context))),
                Text('$value / ${balanceLabel(value, context)}'),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 5,
                backgroundColor: AppColors.line,
                color: AppColors.accentBright,
              ),
            ),
          ],
        ),
      );
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    required this.body,
  });
  final String label, value, body;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _accent(context)),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            if (body.isNotEmpty) Text(body),
          ],
        ),
      );
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.title,
    required this.value,
    this.portraits = const [],
  });
  final String title, value;
  final List<int> portraits;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(color: AppColors.inkSoft),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: _accent(context)),
            if (portraits.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Wrap(
                  spacing: 5,
                  children: portraits
                      .map(
                        (id) => ClipOval(
                          child: SizedBox(
                            width: 45,
                            height: 45,
                            child:
                                ContestantPortrait(contestant: _contestant(id)),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
}

Contestant _contestant(int id) =>
    contestantSeedData.firstWhere((value) => value.id == id);
TextStyle _accent(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
int minOf(int a, int b) => a < b ? a : b;
String balanceLabel(int score, [BuildContext? ctx]) {
  final isEn = isAppEnglish(ctx);
  return score >= 90
      ? (isEn ? 'EXCELLENT' : 'ÇOK GÜÇLÜ')
      : score >= 84
          ? (isEn ? 'STRONG' : 'GÜÇLÜ')
          : score >= 78
              ? (isEn ? 'BALANCED' : 'DENGELİ')
              : score >= 72
                  ? (isEn ? 'VULNERABLE' : 'RİSKLİ')
                  : (isEn ? 'DEVELOPING' : 'GELİŞİYOR');
}

String groupProfile(LineupBalance b, [BuildContext? ctx]) {
  final isEn = isAppEnglish(ctx);
  final values = [b.vocal, b.dance, b.stage, b.camera];
  if (values.reduce((a, b) => a > b ? a : b) -
          values.reduce((a, b) => a < b ? a : b) <=
      5) {
    return isEn ? 'BALANCED QUINTET' : 'DENGELİ BEŞLİ';
  }
  if (b.camera == values.reduce((a, b) => a > b ? a : b)) {
    return isEn ? 'ICONIC POP' : 'İKONİK POP';
  }
  if (b.dance == values.reduce((a, b) => a > b ? a : b)) {
    return isEn ? 'PERFORMANCE UNIT' : 'PERFORMANS ODAKLI';
  }
  if (b.vocal == values.reduce((a, b) => a > b ? a : b)) {
    return isEn ? 'VOCAL POWER' : 'VOKAL GÜCÜ';
  }
  return isEn ? 'STAGE POWER' : 'SAHNE GÜCÜ';
}

String chemistry(int harmony, [BuildContext? ctx]) {
  final isEn = isAppEnglish(ctx);
  return harmony >= 88
      ? (isEn
          ? 'A balanced quintet whose strengths seamlessly complement each other.'
          : 'Rolleri birbirini tamamlayan dengeli bir beşli.')
      : harmony >= 78
          ? (isEn
              ? 'An ensemble uniting vibrant, distinct personalities on one stage.'
              : 'Farklı karakterleri aynı sahnede buluşturan bir grup.')
          : (isEn
              ? 'Composed of strong individual forces. Synergy will flourish with shared experience.'
              : 'Güçlü kişiliklerden oluşuyor. Uyum çalışıldıkça daha da büyüyebilir.');
}

List<(int, String)> _groupDialogue(GameState state, [BuildContext? ctx]) {
  final isEn = isAppEnglish(ctx);
  final ids = state.playerFinalLineupIds.toList()
    ..sort((a, b) => a.compareTo(b));
  return ids.take(3).map((id) {
    final style = groupTaskProfiles[id]!.workStyle;
    final text = switch (style) {
      WorkStyle.playful => isEn
          ? 'When’s first rehearsal? Hopefully not today.'
          : 'İlk prova ne zaman? Bugün değilse iyi.',
      WorkStyle.competitive => isEn
          ? 'The finale ended, but the work never stops.'
          : 'Final bitti diye çalışma bitmedi.',
      WorkStyle.calm =>
        isEn ? 'Let’s catch our breath first.' : 'Önce bir nefes alalım.',
      WorkStyle.bold => isEn
          ? 'Our debut stage has to be even bigger.'
          : 'İlk sahnemiz daha büyük olsun.',
      WorkStyle.social => isEn
          ? 'Let’s go grab food together first.'
          : 'Önce birlikte bir şey yiyelim.',
      WorkStyle.cameraSavvy => isEn
          ? 'I need our first group photoshoot right now.'
          : 'İlk grup çekimimizi istiyorum.',
      _ => isEn
          ? 'Now we’re genuinely on the same team.'
          : 'Şimdi gerçekten aynı takımdayız.',
    };
    return (id, text);
  }).toList();
}

String eliminationPoint(int id, GameState state, [BuildContext? ctx]) {
  final isEn = isAppEnglish(ctx);
  if (state.day2EliminatedContestantId == id) {
    return isEn ? 'DAY 2 — DUEL' : '2. GÜN — DÜELLO';
  }
  if (state.day3FinalCutResultSnapshot?.eliminatedContestantId == id) {
    return isEn ? 'DAY 3 — FINAL CUT' : '3. GÜN — FINAL CUT';
  }
  if (state.day4ResultSnapshot?.eliminatedIds.contains(id) ?? false) {
    final room = state.day4ResultSnapshot!.results[id]!.room;
    return isEn
        ? 'DAY 4 — ${day4RoomLabel(room)}'
        : '4. GÜN — ${day4RoomLabel(room)}';
  }
  if (state.day5EliminatedContestantIds.contains(id)) {
    return isEn ? 'DAY 5 — STAR LIVE' : '5. GÜN — STAR LIVE';
  }
  return isEn ? 'DAY 1 — LAST CHANCE' : '1. GÜN — SON ŞANS';
}

void _showHistory(BuildContext context, int id, GameState state) {
  final isEn = isAppEnglish(context);
  final c = _contestant(id), evaluation = state.evaluation1Results[id];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.inkSoft,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: ContestantPortrait(contestant: c),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    c.displayName,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isEn ? 'FIRST EVALUATION' : 'İLK DEĞERLENDİRME',
              style: _accent(context),
            ),
            Text(
              evaluation == null
                  ? (isEn ? 'No record' : 'Kayıt yok')
                  : (isEn
                      ? 'VOCALS ${evaluation.vocal} • DANCE ${evaluation.dance} • STAGE ${evaluation.stage}'
                      : 'VOKAL ${evaluation.vocal} • DANS ${evaluation.dance} • SAHNE ${evaluation.stage}'),
            ),
            if (state.playerRadarContestantIds.contains(id))
              Text(
                isEn ? '★ Was in your initial radar.' : '★ İlk radarındaydı.',
              ),
            if (state.producerSaveContestantId == id)
              Text(
                isEn
                    ? '★ Protected by the producer.'
                    : '★ Yapımcı tarafından korundu.',
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              state.playerFinalLineupIds.contains(id)
                  ? (isEn ? 'STAR LINEUP MEMBER' : 'YILDIZ KADRO ÜYESİ')
                  : state.day5FinalistIds.contains(id)
                      ? (isEn
                          ? 'FINALIST • Missed the debut lineup.'
                          : 'FİNALİST • Debut kadrosuna giremedi.')
                      : eliminationPoint(id, state, context),
            ),
          ],
        ),
      ),
    ),
  );
}

({bool isValid, String message}) _validateSeason(GameState state) {
  final debut = state.playerFinalLineupIds.toSet(),
      finalists = state.day5FinalistIds.toSet(),
      outside = state.finalistsOutsideDebutLineupIds.toSet(),
      eliminated = state.eliminatedContestantIds.toSet(),
      roles = state.finalMemberPositions.values.toSet(),
      colors = state.finalMemberColors.values.toSet();
  final valid = state.seasonCompleted &&
      debut.length == 5 &&
      finalists.length == 7 &&
      finalists.containsAll(debut) &&
      outside.length == 2 &&
      outside.intersection(debut).isEmpty &&
      eliminated.length == 8 &&
      {...debut, ...outside, ...eliminated}.length == 15 &&
      roles.length == 5 &&
      roles.containsAll(debut) &&
      state.finalMemberPositions.length == 5 &&
      state.finalMemberColors.length == 5 &&
      colors.length == 5 &&
      state.groupName?.trim().isNotEmpty == true &&
      state.finalLineupBalance != null &&
      state.finalLeaderId != null &&
      debut.contains(state.finalLeaderId) &&
      state.automaticGroupTags.isNotEmpty;
  return (
    isValid: valid,
    message: valid
        ? ''
        : 'Sezon finali verileri henüz tamamlanmadı. Önce mevcut oyun akışına dön.',
  );
}

class _IncompleteSeasonScreen extends StatelessWidget {
  const _IncompleteSeasonScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAppEnglish(context)
                          ? 'SEASON NOT YET COMPLETED'
                          : 'SEZON HENÜZ TAMAMLANMADI',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: isAppEnglish(context)
                          ? 'RETURN TO GAME'
                          : 'OYUNA DÖN',
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        if (navigator.canPop()) {
                          navigator.pop();
                        } else {
                          navigator.pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
