import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/navigation/game_navigation_observer.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant_localization.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/producer/domain/contestant_social_state.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/shared/widgets/language_selector.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key, this.day});
  final int? day;

  static Route<void> route({int? day}) => MaterialPageRoute<void>(
        settings:
            const RouteSettings(name: GameNavigationObserver.dashboardRoute),
        builder: (_) => ProducerDashboardScreen(day: day),
      );

  @override
  State<ProducerDashboardScreen> createState() =>
      _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  int index = 0;

  bool _isEn(BuildContext context) => isAppEnglish(context);

  List<String> _labels(BuildContext context) => _isEn(context)
      ? const ['CONTESTANTS', 'TEAMS', 'BACKSTAGE', 'AGENDA', 'JURY', 'SEASON']
      : const ['YARIŞMACILAR', 'TAKIMLAR', 'KULİS', 'GÜNDEM', 'JÜRİ', 'SEZON'];

  int _activeDay(GameState state) => widget.day ?? state.currentDay;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final day = _activeDay(state);
    final isEn = _isEn(context);
    final labels = _labels(context);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: Text(context.l10n.producerDesk),
        actions: [
          const Center(child: LanguageSelector()),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text(
                context.l10n.dayLabel(day),
                style: const TextStyle(
                  color: AppColors.accentBright,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(
                    isEn ? 'RESUME GAMEPLAY' : 'KALDIĞIN YERDEN DEVAM ET',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                scrollDirection: Axis.horizontal,
                itemCount: labels.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, tab) => ChoiceChip(
                  label: Text(labels[tab]),
                  selected: index == tab,
                  onSelected: (_) => _selectTab(state, tab),
                ),
              ),
            ),
            Expanded(child: _content(state)),
          ],
        ),
      ),
    );
  }

  Widget _content(GameState state) => switch (index) {
        0 => _contestants(state),
        1 => _teams(state),
        2 => _backstage(state),
        3 => _agenda(state),
        4 => _coaches(state),
        _ => _season(state),
      };

  void _selectTab(GameState state, int tab) {
    if (tab == 2) state.prepareStoryEvent(_activeDay(state));
    if (!mounted || index == tab) return;
    setState(() => index = tab);
  }

  Widget _scroll(List<Widget> children) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: children,
      );

  Widget _contestants(GameState state) {
    final isEn = _isEn(context);
    final active = contestantSeedData.where(
      (member) => !state.eliminatedContestantIds.contains(member.id),
    );
    return _scroll(
      active.map((member) {
        final social = state.socialStateFor(member.id);
        final followerLabel = isEn ? 'FOLLOWERS' : 'TAKİPÇİ';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: ClipOval(
            child: SizedBox(
              width: 52,
              height: 52,
              child: ContestantPortrait(contestant: member),
            ),
          ),
          title: Text(member.displayName),
          subtitle: Text(
            '${social.currentForm}  •  ${_followers(social.followers)} $followerLabel',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showDossier(state, member),
        );
      }).toList(),
    );
  }

  Widget _teams(GameState state) {
    final isEn = _isEn(context);
    if (!state.day2TeamFormationCompleted) {
      return _scroll([
        _Panel(
          isEn ? 'TEAMS NOT YET LOCKED' : 'TAKIMLAR HENÜZ KİLİTLENMEDİ',
          isEn
              ? 'Teams are formed during the Day 2 Group Mission.'
              : 'Takımlar 2. Gün Grup Görevi sırasında oluşturulur.',
        ),
      ]);
    }
    return _scroll([
      _teamCard(
        title: context.l10n.teamA,
        captainId: state.day2CaptainAId,
        memberIds: state.day2TeamAIds,
        state: state,
      ),
      const SizedBox(height: AppSpacing.md),
      _teamCard(
        title: context.l10n.teamB,
        captainId: state.day2CaptainBId,
        memberIds: state.day2TeamBIds,
        state: state,
      ),
    ]);
  }

  Widget _teamCard({
    required String title,
    required int? captainId,
    required List<int> memberIds,
    required GameState state,
  }) {
    final isEn = _isEn(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _accent()),
          const SizedBox(height: AppSpacing.md),
          if (captainId != null)
            Text(
              '${isEn ? "CAPTAIN" : "KAPTAN"}: ${_name(captainId)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: AppSpacing.sm),
          ...memberIds.map((id) {
            final contestant = contestantSeedData.firstWhere((c) => c.id == id);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${contestant.displayName} (${contestant.localizedPrimaryRole(context)})',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _backstage(GameState state) {
    final isEn = _isEn(context);
    final day = _activeDay(state);
    final record = state.eventHistory.cast<StoryEventRecord?>().firstWhere(
          (entry) => entry?.day == day,
          orElse: () => null,
        );
    if (record == null) {
      return _scroll([
        _Panel(
          context.l10n.backstagePreparing,
          day > 5
              ? (isEn
                  ? 'Grand Final: No backstage crises scheduled.'
                  : 'Büyük Final: Kulis krizi planlanmadı.')
              : context.l10n.backstagePreparingDesc,
        ),
      ]);
    }
    final choice = record.choiceId == null
        ? null
        : record.event.choices.firstWhere(
            (value) => value.id == record.choiceId,
          );
    return _scroll([
      Text(_category(context, record.event.category), style: _accent()),
      const SizedBox(height: AppSpacing.md),
      _Panel(
        record.event.localizedTitle(context),
        '${record.event.contestantIds.map(_name).join(' & ')}\n${record.event.localizedBody(context)}',
      ),
      _Panel(context.l10n.why, record.event.localizedWhy(context)),
      if (record.event.localizedConfessional(context) != null)
        _Panel(
          isEn ? 'BACKSTAGE INTERVIEW' : 'KULİS RÖPORTAJI',
          record.event.localizedConfessional(context)!,
        ),
      if (choice == null)
        ...record.event.choices.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                color: AppColors.inkSoft,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      option.localizedLabel(context),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => state.resolveStoryEvent(
                        day: day,
                        choiceId: option.id,
                      ),
                      child: Text(context.l10n.applyThisDecision),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      else
        _Panel(
          context.l10n.decisionApplied,
          '${choice.localizedFeedback(context)}\n${_resultSummary(record)}',
        ),
      const SizedBox(height: AppSpacing.xl),
      Text(context.l10n.history, style: _accent()),
      ...state.eventHistory.reversed
          .where((event) => event.choiceId != null && event.day != day)
          .map(
            (event) => ListTile(
              title: Text(
                '${context.l10n.dayLabel(event.day)} • ${event.event.localizedTitle(context)}',
              ),
              subtitle: Text(
                event.event.choices
                    .firstWhere((choice) => choice.id == event.choiceId)
                    .localizedFeedback(context),
              ),
            ),
          ),
    ]);
  }

  String _category(BuildContext context, StoryEventCategory category) =>
      switch (category) {
        StoryEventCategory.crisis => context.l10n.crisis,
        StoryEventCategory.positive => context.l10n.positiveDevelopment,
        StoryEventCategory.social => context.l10n.socialDevelopment,
        StoryEventCategory.performance => context.l10n.performanceDevelopment,
        StoryEventCategory.relationship => context.l10n.relationshipEvent,
      };

  String _resultSummary(StoryEventRecord record) {
    final lines = <String>[];
    for (final id in record.event.contestantIds) {
      final before = record.before[id] ?? const {};
      final after = record.after[id] ?? const {};
      final changes = after.entries
          .where(
        (entry) =>
            before.containsKey(entry.key) && before[entry.key] != entry.value,
      )
          .map((entry) {
        final delta = entry.value - (before[entry.key] ?? entry.value);
        final sign = delta > 0 ? '+' : '';
        return '${_metricName(entry.key)} $sign$delta';
      }).toList();
      if (changes.isNotEmpty) {
        lines.add('${_name(id)}: ${changes.join(', ')}');
      }
    }
    return lines.join('\n');
  }

  String _metricName(String key) => switch (key) {
        'morale' || 'motivation' => context.l10n.motivation,
        'popularity' => context.l10n.popularity,
        'buzz' => 'Buzz',
        'followers' => context.l10n.followers,
        'confidence' => context.l10n.confidence,
        'professionalism' => context.l10n.professionalism,
        'energy' => context.l10n.energy,
        'preparation' => context.l10n.preparation,
        'relationship' => context.l10n.relationship,
        'vocalCoach' => context.l10n.vocalCoach,
        'danceCoach' => context.l10n.danceCoach,
        _ => key,
      };

  Widget _agenda(GameState state) {
    final isEn = _isEn(context);
    final entries = state.contestantSocialStates.entries
        .where((entry) => !state.eliminatedContestantIds.contains(entry.key))
        .toList();
    if (entries.isEmpty) return _scroll([]);
    int top(int Function(ContestantSocialState) score) =>
        (entries..sort((a, b) => score(b.value).compareTo(score(a.value))))
            .first
            .key;
    return _scroll([
      _Panel(
        isEn ? 'FAN FAVORITE' : 'FAN FAVORİSİ',
        _name(top((value) => value.popularity)),
      ),
      _Panel(
        isEn ? 'TOP BUZZ' : 'EN ÇOK KONUŞULAN',
        _name(top((value) => value.buzz)),
      ),
      _Panel(
        isEn ? 'FASTEST GROWING' : 'EN HIZLI BÜYÜYEN',
        _name(top((value) => value.weeklyFollowerGrowth)),
      ),
      _Panel(
        isEn ? 'LARGEST AUDIENCE' : 'EN GENİŞ KİTLE',
        _name(top((value) => value.followers)),
      ),
    ]);
  }

  Widget _coaches(GameState state) {
    final isEn = _isEn(context);
    final active = contestantSeedData
        .where((member) => !state.eliminatedContestantIds.contains(member.id))
        .toList();
    if (active.isEmpty) return _scroll([]);
    active.sort((a, b) => (b.vocal + b.dance).compareTo(a.vocal + a.dance));
    final vocal = [...active]..sort((a, b) => b.vocal.compareTo(a.vocal));
    final dance = [...active]..sort((a, b) => b.dance.compareTo(a.dance));
    return _scroll([
      _Panel(
        isEn ? 'CONSULT COACHES' : 'HOCALARA SOR',
        isEn
            ? 'Insights offer guidance; they grant no score bonus and the final call is always yours.'
            : 'Görüşleri bilgi verir; puan bonusu sağlamaz ve son karar her zaman senindir.',
      ),
      _Panel(
        isEn ? 'VOCAL COACH' : 'VOKAL HOCASI',
        isEn
            ? '${vocal.first.displayName} is the most reliable live vocalist. ${vocal[1].displayName} is being closely tracked for growth.'
            : '${vocal.first.displayName} canlı vokalde en güvenli isim. ${vocal[1].displayName} gelişim takibinde.',
      ),
      _Panel(
        isEn ? 'DANCE COACH' : 'DANS HOCASI',
        isEn
            ? '${dance.first.displayName} picks up choreography fastest. ${dance[1].displayName} shows commanding stage presence.'
            : '${dance.first.displayName} koreografiyi en hızlı taşıyor. ${dance[1].displayName} sahne görünürlüğünde güçlü.',
      ),
      ...active.take(5).map((member) {
        final social = state.socialStateFor(member.id);
        return ListTile(
          title: Text(member.displayName),
          subtitle: Text(
            isEn
                ? 'Vocal note: ${social.vocalCoachImpression}  •  Dance note: ${social.danceCoachImpression}\nPrep: ${social.preparation}  •  Professionalism: ${social.professionalism}'
                : 'Vokal görüşü ${social.vocalCoachImpression}  •  Dans görüşü ${social.danceCoachImpression}\nHazırlık ${social.preparation}  •  Profesyonellik ${social.professionalism}',
          ),
        );
      }),
    ]);
  }

  Widget _season(GameState state) {
    final isEn = _isEn(context);
    final lockedCount =
        state.eventHistory.where((event) => event.choiceId != null).length;
    return _scroll([
      _Panel(
        isEn ? 'INITIAL RADAR' : 'İLK RADAR',
        state.playerRadarContestantIds.map(_name).join(' • '),
      ),
      if (state.day2CaptainAId != null)
        _Panel(
          isEn ? 'CAPTAIN PICKS' : 'KAPTAN SEÇİMİ',
          '${_name(state.day2CaptainAId!)} • ${_name(state.day2CaptainBId!)}',
        ),
      _Panel(
        isEn ? 'ELIMINATIONS' : 'VEDALAR',
        state.eliminatedContestantIds.isEmpty
            ? (isEn ? 'None yet.' : 'Henüz yok.')
            : state.eliminatedContestantIds.map(_name).join(' • '),
      ),
      _Panel(
        isEn ? 'STORY DECISIONS' : 'HİKÂYE KARARLARI',
        isEn
            ? '$lockedCount decisions locked.'
            : '$lockedCount karar kilitlendi.',
      ),
    ]);
  }

  void _showDossier(GameState state, Contestant member) {
    final isEn = _isEn(context);
    final social = state.socialStateFor(member.id);
    final identity = identityFor(member);
    final relations = contestantSeedData
        .where(
          (other) =>
              other.id != member.id &&
              !state.eliminatedContestantIds.contains(other.id),
        )
        .map(
          (other) =>
              '${other.displayName}: ${relationshipLabel(state.relationshipBetween(member.id, other.id))}',
        )
        .take(4)
        .join('\n');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.inkSoft,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: ContestantPortrait(contestant: member),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${member.displayName} — ${member.age}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                member.localizedOccupation(context),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.paperMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                member.localizedShortBackground(context),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(isEn ? 'GOAL' : 'HEDEF', style: _accent()),
              Text(identity.goal),
              const SizedBox(height: AppSpacing.sm),
              Text(isEn ? 'STRENGTH' : 'GÜÇLÜ YANI', style: _accent()),
              Text(member.localizedSpecialTraitDescription(context)),
              const SizedBox(height: AppSpacing.sm),
              Text(isEn ? 'WATCH OUT' : 'DİKKAT', style: _accent()),
              Text(member.localizedRiskDescription(context)),
              const SizedBox(height: AppSpacing.md),
              Text(
                isEn
                    ? 'VOCAL ${member.vocal}  •  DANCE ${member.dance}  •  STAGE ${member.stage}'
                    : 'VOKAL ${member.vocal}  •  DANS ${member.dance}  •  SAHNE ${member.stage}',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                isEn
                    ? 'MOTIVATION ${social.motivation}  •  POPULARITY ${social.popularity}\nGROWTH ${social.experienceXp} XP  •  LEVEL ${social.level}\nBUZZ ${social.buzz}  •  ${_followers(social.followers)} FOLLOWERS\nTHIS WEEK +${_followers(social.weeklyFollowerGrowth)}  •  FORM ${social.currentForm}'
                    : 'MOTİVASYON ${social.motivation}  •  POPÜLARİTE ${social.popularity}\nGELİŞİM ${social.experienceXp} XP  •  SEVİYE ${social.level}\nBUZZ ${social.buzz}  •  ${_followers(social.followers)} TAKİPÇİ\nBU HAFTA +${_followers(social.weeklyFollowerGrowth)}  •  FORM ${social.currentForm}',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(isEn ? 'RELATIONSHIPS' : 'İLİŞKİLER', style: _accent()),
              Text(relations),
              const SizedBox(height: AppSpacing.md),
              Text(
                isEn ? 'FOLLOWER HISTORY' : 'TAKİPÇİ GEÇMİŞİ',
                style: _accent(),
              ),
              ...social.followerHistory.map((snapshot) {
                final dayStr = snapshot.day == 0
                    ? (isEn ? 'START' : 'BAŞLANGIÇ')
                    : (isEn ? 'DAY ${snapshot.day}' : '${snapshot.day}. GÜN');
                return Text(
                  '$dayStr  ${_followers(snapshot.count)}  •  ${snapshot.reason}',
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _name(int id) =>
      contestantSeedData.firstWhere((member) => member.id == id).displayName;
  String _followers(int value) => value.abs() >= 1000000
      ? '${(value / 1000000).toStringAsFixed(1)}M'
      : '${(value / 1000).round()}K';
  TextStyle _accent() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
}

class _Panel extends StatelessWidget {
  const _Panel(this.title, this.body);
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: AppColors.accentBright, letterSpacing: 1.1),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}
