import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/producer/domain/contestant_social_state.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key, this.day = 2});
  final int day;

  @override
  State<ProducerDashboardScreen> createState() =>
      _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  int index = 0;
  static const labels = [
    'YARIŞMACILAR',
    'TAKIMLAR',
    'KULİS',
    'GÜNDEM',
    'JÜRİ',
    'SEZON',
  ];

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(title: const Text('YAPIMCI MASASI')),
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
                  label: const Text('KALDIĞIN YERDEN DEVAM ET'),
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
    if (tab == 2) state.prepareStoryEvent(widget.day);
    if (!mounted || index == tab) return;
    setState(() => index = tab);
  }

  Widget _scroll(List<Widget> children) => ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: children,
      );

  Widget _contestants(GameState state) {
    final active = contestantSeedData.where(
      (member) => !state.eliminatedContestantIds.contains(member.id),
    );
    return _scroll(
      active.map((member) {
        final social = state.socialStateFor(member.id);
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
            '${social.currentForm}  •  ${_followers(social.followers)} TAKİPÇİ',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showDossier(state, member),
        );
      }).toList(),
    );
  }

  Widget _teams(GameState state) {
    if (!state.day2TeamFormationCompleted) {
      return _scroll([
        const _Panel(
          'TAKIMLAR HENÜZ KİLİTLENMEDİ',
          'Takım kurma ekranındaki seçimlerin burada salt okunur görünecek.',
        ),
      ]);
    }
    return _scroll([
      _teamPanel(
        'A TAKIMI',
        state.day2CaptainAId!,
        state.day2TeamAIds,
        state.day2RehearsalSetup?.teamARoles,
      ),
      _teamPanel(
        'B TAKIMI',
        state.day2CaptainBId!,
        state.day2TeamBIds,
        state.day2RehearsalSetup?.teamBRoles,
      ),
    ]);
  }

  Widget _teamPanel(
    String title,
    int captain,
    List<int> ids,
    dynamic roles,
  ) =>
      _Panel(
        '$title  •  KAPTAN ${_name(captain)}',
        '${ids.map(_name).join(' • ')}${roles == null ? '' : '\nCENTER ${_name(roles.centerId)}  •  ANA VOKAL ${_name(roles.mainVocalId)}  •  DANS LİDERİ ${_name(roles.danceLeadId)}'}',
      );

  Widget _backstage(GameState state) {
    final record = state.storyEventForDay(widget.day);
    if (record == null) {
      return _scroll([
        const _Panel(
          'KULİS HAZIRLANIYOR',
          'Günün gelişmeleri kısa süre içinde yapımcı masasına düşecek.',
        ),
      ]);
    }
    final choice = record.choiceId == null
        ? null
        : record.event.choices.firstWhere(
            (value) => value.id == record.choiceId,
          );
    return _scroll([
      Text(_category(record.event.category), style: _accent()),
      const SizedBox(height: AppSpacing.md),
      _Panel(
        record.event.title,
        '${record.event.contestantIds.map(_name).join(' & ')}\n${record.event.body}',
      ),
      _Panel('NEDEN?', record.event.why),
      if (record.event.confessional != null)
        _Panel('KULİS RÖPORTAJI', record.event.confessional!),
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
                      option.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => state.resolveStoryEvent(
                        day: widget.day,
                        choiceId: option.id,
                      ),
                      child: const Text('BU KARARI UYGULA'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      else
        _Panel(
          'KARAR UYGULANDI',
          '${choice.feedback}\n${_resultSummary(record)}',
        ),
      const SizedBox(height: AppSpacing.xl),
      Text('GEÇMİŞ', style: _accent()),
      ...state.eventHistory.reversed
          .where((event) => event.choiceId != null && event.day != widget.day)
          .map(
            (event) => ListTile(
              title: Text('${event.day}. GÜN • ${event.event.title}'),
              subtitle: Text(
                event.event.choices
                    .firstWhere((choice) => choice.id == event.choiceId)
                    .feedback,
              ),
            ),
          ),
    ]);
  }

  String _category(StoryEventCategory category) => switch (category) {
        StoryEventCategory.crisis => 'KRİZ',
        StoryEventCategory.positive => 'OLUMLU GELİŞME',
        StoryEventCategory.social => 'SOSYAL GELİŞME',
        StoryEventCategory.performance => 'PERFORMANS GELİŞMESİ',
        StoryEventCategory.relationship => 'İLİŞKİ OLAYI',
      };

  String _resultSummary(StoryEventRecord record) {
    final lines = <String>[];
    for (final id in record.event.contestantIds) {
      final before = record.before[id] ?? const {};
      final after = record.after[id] ?? const {};
      final changes = after.entries
          .where(
            (entry) =>
                before[entry.key] != null && before[entry.key] != entry.value,
          )
          .map(
            (entry) =>
                '${_metric(entry.key)} ${before[entry.key]} → ${entry.value}',
          )
          .join('  •  ');
      if (changes.isNotEmpty) lines.add('${_name(id)}\n$changes');
    }
    return lines.join('\n');
  }

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
        'vocalCoach' => 'Vokal hoca',
        'danceCoach' => 'Dans hoca',
        _ => key,
      };

  Widget _agenda(GameState state) {
    final entries = state.contestantSocialStates.entries
        .where((entry) => !state.eliminatedContestantIds.contains(entry.key))
        .toList();
    int top(int Function(ContestantSocialState) score) =>
        (entries..sort((a, b) => score(b.value).compareTo(score(a.value))))
            .first
            .key;
    return _scroll([
      _Panel('FAN FAVORİSİ', _name(top((value) => value.popularity))),
      _Panel('EN ÇOK KONUŞULAN', _name(top((value) => value.buzz))),
      _Panel(
        'EN HIZLI BÜYÜYEN',
        _name(top((value) => value.weeklyFollowerGrowth)),
      ),
      _Panel('EN GENİŞ KİTLE', _name(top((value) => value.followers))),
    ]);
  }

  Widget _coaches(GameState state) {
    final active = contestantSeedData
        .where((member) => !state.eliminatedContestantIds.contains(member.id))
        .toList();
    active.sort((a, b) => (b.vocal + b.dance).compareTo(a.vocal + a.dance));
    final vocal = [...active]..sort((a, b) => b.vocal.compareTo(a.vocal));
    final dance = [...active]..sort((a, b) => b.dance.compareTo(a.dance));
    return _scroll([
      const _Panel(
        'HOCALARA SOR',
        'Görüşleri bilgi verir; puan bonusu sağlamaz ve son karar her zaman senindir.',
      ),
      _Panel(
        'VOKAL HOCASI',
        '${vocal.first.displayName} canlı vokalde en güvenli isim. ${vocal[1].displayName} gelişim takibinde.',
      ),
      _Panel(
        'DANS HOCASI',
        '${dance.first.displayName} koreografiyi en hızlı taşıyor. ${dance[1].displayName} sahne görünürlüğünde güçlü.',
      ),
      ...active.take(5).map((member) {
        final social = state.socialStateFor(member.id);
        return ListTile(
          title: Text(member.displayName),
          subtitle: Text(
            'Vokal görüşü ${social.vocalCoachImpression}  •  Dans görüşü ${social.danceCoachImpression}\nHazırlık ${social.preparation}  •  Profesyonellik ${social.professionalism}',
          ),
        );
      }),
    ]);
  }

  Widget _season(GameState state) => _scroll([
        _Panel(
            'İLK RADAR', state.playerRadarContestantIds.map(_name).join(' • ')),
        if (state.day2CaptainAId != null)
          _Panel(
            'KAPTAN SEÇİMİ',
            '${_name(state.day2CaptainAId!)} • ${_name(state.day2CaptainBId!)}',
          ),
        _Panel(
          'VEDALAR',
          state.eliminatedContestantIds.isEmpty
              ? 'Henüz yok.'
              : state.eliminatedContestantIds.map(_name).join(' • '),
        ),
        _Panel(
          'HİKÂYE KARARLARI',
          '${state.eventHistory.where((event) => event.choiceId != null).length} karar kilitlendi.',
        ),
      ]);

  void _showDossier(GameState state, Contestant member) {
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
                identity.hook,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('HEDEF', style: _accent()),
              Text(identity.goal),
              const SizedBox(height: AppSpacing.sm),
              Text('GÜÇLÜ YANI', style: _accent()),
              Text(identity.characterStrength),
              const SizedBox(height: AppSpacing.sm),
              Text('DİKKAT', style: _accent()),
              Text(identity.sensitivity),
              const SizedBox(height: AppSpacing.md),
              Text(
                'VOKAL ${member.vocal}  •  DANS ${member.dance}  •  SAHNE ${member.stage}',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'MOTİVASYON ${social.motivation}  •  POPÜLARİTE ${social.popularity}\nGELİŞİM ${social.experienceXp} XP  •  SEVİYE ${social.level}\nBUZZ ${social.buzz}  •  ${_followers(social.followers)} TAKİPÇİ\nBU HAFTA +${_followers(social.weeklyFollowerGrowth)}  •  FORM ${social.currentForm}',
              ),
              const SizedBox(height: AppSpacing.md),
              Text('İLİŞKİLER', style: _accent()),
              Text(relations),
              const SizedBox(height: AppSpacing.md),
              Text('TAKİPÇİ GEÇMİŞİ', style: _accent()),
              ...social.followerHistory.map(
                (snapshot) => Text(
                  '${snapshot.day == 0 ? 'BAŞLANGIÇ' : '${snapshot.day}. GÜN'}  ${_followers(snapshot.count)}  •  ${snapshot.reason}',
                ),
              ),
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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(body),
          ],
        ),
      );
}
