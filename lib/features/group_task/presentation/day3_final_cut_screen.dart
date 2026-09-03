import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day3_final_cut_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_final_cut_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day3_results_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/contestant_dialogue_bubble.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase {
  intro,
  compare,
  format,
  approach,
  summary,
  performance,
  preReveal,
  scores,
  survivor,
  farewell,
}

class Day3FinalCutScreen extends StatefulWidget {
  const Day3FinalCutScreen({super.key});
  @override
  State<Day3FinalCutScreen> createState() => _Day3FinalCutScreenState();
}

class _Day3FinalCutScreenState extends State<Day3FinalCutScreen> {
  _Phase _phase = _Phase.intro;
  Day3FinalCutFormat? _format;
  Day3FinalCutApproach? _approach;
  Day3FinalCutResultSnapshot? _result;
  int _performance = 0;
  Contestant _c(int id) => contestantSeedData.firstWhere((c) => c.id == id);
  void _go(_Phase p) => setState(() => _phase = p);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    final pair = state.day3FinalCutContestantIds;
    final storedResult = state.day3FinalCutResultSnapshot;
    if (storedResult != null) {
      if (pair.length != 2 ||
          !storedResult.results.keys.toSet().containsAll(pair)) {
        throw StateError('Kaydedilmiş Final Cut sonucu geçersiz.');
      }
      _result = storedResult;
      _phase = _Phase.survivor;
      return;
    }
    if (pair.length != 2 ||
        pair.toSet().length != 2 ||
        pair.any(state.eliminatedContestantIds.contains) ||
        state.day3IconResultSnapshot!.jurySavedIds
            .toSet()
            .intersection(pair.toSet())
            .isNotEmpty) {
      throw StateError('Final Cut ikilisi geçersiz.');
    }
  }

  void _start() {
    final state = GameScope.of(context);
    _result = calculateDay3FinalCut(
      contestantIds: state.day3FinalCutContestantIds,
      format: _format!,
      approach: _approach!,
      firstResults: state.evaluation1Results,
      icon: state.day3IconResultSnapshot!,
      setup: state.day3IdentitySetupSnapshot!,
    );
    _go(_Phase.performance);
  }

  void _commitAndShowSurvivor() {
    final result = _result;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Final Cut sonucu hazırlanamadı.')),
      );
      return;
    }
    final state = GameScope.of(context);
    try {
      if (state.day3FinalCutResultSnapshot == null) {
        state.completeDay3FinalCut(result);
      }
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const Day3FinalCutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ids = GameScope.of(context).day3FinalCutContestantIds;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (_phase) {
            _Phase.intro => _intro(ids),
            _Phase.compare => _compare(ids),
            _Phase.format => _choiceFormat(ids),
            _Phase.approach => _choiceApproach(ids),
            _Phase.summary => _summary(ids),
            _Phase.performance => _performanceView(ids),
            _Phase.preReveal => _preReveal(ids),
            _Phase.scores => _scores(ids),
            _Phase.survivor => _survivor(),
            _Phase.farewell => _farewell(),
          },
        ),
      ),
    );
  }

  Widget _intro(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dayLabel(3), style: _label(context)),
          Text('FINAL CUT', style: _label(context)),
          Text(
            isEn
                ? 'The final frame can change everything.'
                : 'Son kare her şeyi değiştirebilir.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ContestantDialogueBubble(
            contestant: _c(ids.first),
            text: dialogueFor(ids.first, 'confrontation', context),
          ),
          const SizedBox(height: AppSpacing.lg),
          ContestantDialogueBubble(
            contestant: _c(ids.last),
            text: dialogueFor(ids.last, 'confrontation', context),
            alignRight: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isEn
                ? 'The jury did not save them.\nNow only one will remain in the final frame.'
                : 'Jüri onları kurtarmadı.\nŞimdi yalnızca biri son karede kalacak.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            isEn
                ? 'This time you define the conditions of the camera test.'
                : 'Bu kez kamera testinin koşullarını sen belirleyeceksin.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'SET UP FINAL TEST  ★ →' : 'SON TESTİ KUR  ★ →',
            onPressed: () => _go(_Phase.compare),
          ),
        ],
      ),
    );
  }

  Widget _compare(List<int> ids) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CASTING NOTES',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...ids.map((id) {
            final r = state.day3IconResultSnapshot!.results[id]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: ContestantPortrait(contestant: _c(id)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _c(id).displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${state.day3IdentitySetupSnapshot!.allocation.conceptByContestantId[id]!.name.toUpperCase()} • ${groupTaskProfiles[id]!.primaryRole.name.toUpperCase()}',
                          style: _label(context),
                        ),
                        Text(
                          isEn
                              ? 'IDENTITY ${r.identity}  STYLING ${r.styling}  CAMERA ${r.camera}  PERFORMANCE ${r.performance}'
                              : 'KİMLİK ${r.identity}  STYLING ${r.styling}  KAMERA ${r.camera}  PERFORMANS ${r.performance}',
                        ),
                        Text('ICON ${r.iconScore}', style: _label(context)),
                        if (state.playerRadarContestantIds.contains(id))
                          Text(
                            isEn ? '★ ON RADAR' : '★ RADARINDA',
                            style: _label(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          AppButton(
            label: isEn ? 'CHOOSE FINAL FRAME' : 'SON KAREYİ SEÇ',
            onPressed: () => _go(_Phase.format),
          ),
        ],
      ),
    );
  }

  Widget _choiceFormat(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _choice(
      isEn ? 'HOW SHOULD THE FINAL FRAME BE SHOT?' : 'SON KARE NASIL ÇEKİLSİN?',
      Day3FinalCutFormat.values
          .map(
            (v) => (
              finalCutFormatLabel(v),
              _formatDescription(v, context),
              _format == v,
              () => setState(() => _format = v),
            ),
          )
          .toList(),
      _format == null ? null : () => _go(_Phase.approach),
      ids,
      'format',
    );
  }

  Widget _choiceApproach(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _choice(
      isEn
          ? 'WHAT DO YOU WANT IN THE FINAL FRAME?'
          : 'SON KAREDE NE İSTİYORSUN?',
      Day3FinalCutApproach.values
          .map(
            (v) => (
              finalCutApproachLabel(v, context),
              v == Day3FinalCutApproach.perfectFrame
                  ? (isEn
                      ? 'Controlled, clean, and reliable execution.'
                      : 'Kontrollü, net ve güvenli bir sonuç.')
                  : (isEn
                      ? 'More risk. More distinct character.'
                      : 'Daha fazla risk. Daha fazla karakter.'),
              _approach == v,
              () => setState(() => _approach = v),
            ),
          )
          .toList(),
      _approach == null ? null : () => _go(_Phase.summary),
      ids,
      'approach',
    );
  }

  Widget _choice(
    String title,
    List<(String, String, bool, VoidCallback)> items,
    VoidCallback? next,
    List<int> ids,
    String scene,
  ) =>
      _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppSpacing.xl),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  onTap: e.$4,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: e.$3 ? AppColors.accentInk : AppColors.inkSoft,
                      border: Border.all(
                        color: e.$3 ? AppColors.accentBright : AppColors.line,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.$1,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(e.$2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (items.any((e) => e.$3)) ...[
              ContestantDialogueBubble(
                contestant: _c(ids.first),
                text: dialogueFor(ids.first, scene, context),
              ),
              const SizedBox(height: AppSpacing.sm),
              ContestantDialogueBubble(
                contestant: _c(ids.last),
                text: dialogueFor(ids.last, scene, context),
                alignRight: true,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: isAppEnglish(context) ? 'CONTINUE' : 'DEVAM ET',
              onPressed: next,
            ),
          ],
        ),
      );
  Widget _summary(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'FINAL CUT READY' : 'FINAL CUT HAZIR',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          _line(isEn ? 'MATERIAL' : 'MATERYAL', finalCutFormatLabel(_format!)),
          _line(
            isEn ? 'APPROACH' : 'YAKLAŞIM',
            finalCutApproachLabel(_approach!, context),
          ),
          const SizedBox(height: AppSpacing.xl),
          ContestantDialogueBubble(
            contestant: _c(ids.first),
            text: isEn ? 'Ready.' : 'Hazırım.',
          ),
          const SizedBox(height: AppSpacing.md),
          ContestantDialogueBubble(
            contestant: _c(ids.last),
            text: isEn ? 'Stepping up one last time.' : 'Son kez çıkıyorum.',
            alignRight: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: () => _go(_Phase.format),
            child: Text(isEn ? 'CHANGE' : 'DEĞİŞTİR'),
          ),
          AppButton(
            label: isEn ? 'ROLL CAMERA  ★ →' : 'KAMERAYI AÇ  ★ →',
            onPressed: _start,
          ),
        ],
      ),
    );
  }

  Widget _performanceView(List<int> ids) {
    final isEn = isAppEnglish(context);
    final id = ids[_performance];
    final r = _result!.results[id]!;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn
                ? 'FINAL CUT — ${_performance + 1} / 2'
                : 'FINAL CUT — ${_performance + 1} / 2',
            style: _label(context),
          ),
          Text(finalCutFormatLabel(_result!.format), style: _label(context)),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
            ),
            child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: _c(id)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _c(id).displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          _line(
            isEn ? 'CAMERA' : 'KAMERA',
            r.testFitModifier >= 3
                ? (isEn ? 'STRONG' : 'GÜÇLÜ')
                : (isEn ? 'BALANCED' : 'DENGELİ'),
          ),
          _line(
            isEn ? 'EXECUTION' : 'UYGULAMA',
            r.approachModifier >= 2
                ? (isEn ? 'CLEAN' : 'NET')
                : (isEn ? 'RISKY' : 'RİSKLİ'),
          ),
          _line(
            isEn ? 'IMPACT' : 'ETKİ',
            r.totalModifier >= 5
                ? (isEn ? 'MEMORABLE' : 'AKILDA KALICI')
                : (isEn ? 'COMPOSED' : 'SAKİN'),
          ),
          ContestantDialogueBubble(
            contestant: _c(id),
            text: dialogueFor(id, 'after', context),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _performance == 0
                ? (isEn ? 'SECOND TAKE' : 'İKİNCİ ÇEKİM')
                : (isEn ? 'COMPLETE FINAL CUT' : 'FINAL CUT’I TAMAMLA'),
            onPressed: () {
              if (_performance == 0) {
                setState(() => _performance = 1);
              } else {
                _go(_Phase.preReveal);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _preReveal(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'FINAL CUT CONCLUDED' : 'FINAL CUT TAMAMLANDI',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ContestantDialogueBubble(
            contestant: _c(ids.first),
            text: isEn
                ? 'Whatever happens, I put myself out there.'
                : 'Ne olursa olsun kendimi gösterdim.',
          ),
          const SizedBox(height: AppSpacing.lg),
          ContestantDialogueBubble(
            contestant: _c(ids.last),
            text: isEn ? 'I want to stay here.' : 'Burada kalmak istiyorum.',
            alignRight: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isEn ? 'The final frame is chosen.' : 'Son kare seçildi.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          AppButton(
            label: isEn ? 'REVEAL RESULT  →' : 'SONUCU AÇ  →',
            onPressed: () => _go(_Phase.scores),
          ),
        ],
      ),
    );
  }

  Widget _scores(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'FINAL FRAME' : 'SON KARE',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ...ids.map(
            (id) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipOval(
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: ContestantPortrait(contestant: _c(id)),
                ),
              ),
              title: Text(_c(id).displayName),
              trailing: Text(
                'FINAL CUT ${_result!.results[id]!.finalScore}',
                style: _label(context),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'REVEAL SURVIVOR' : 'GÜVENDEKİ İSMİ AÇ',
            onPressed: _commitAndShowSurvivor,
          ),
        ],
      ),
    );
  }

  Widget _survivor() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final id = _result!.winnerContestantId;
    return _Page(
      child: Column(
        children: [
          Text(
            isEn ? 'SURVIVED FINAL FRAME' : 'SON KAREDE KALAN',
            style: _label(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 350,
            child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: _c(id)),
            ),
          ),
          Text(
            _c(id).displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn ? 'SAFE' : 'GÜVENDE',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: AppColors.accentBright),
          ),
          Text(
            'FINAL CUT ${_result!.results[id]!.finalScore}',
            style: _label(context),
          ),
          ContestantDialogueBubble(
            contestant: _c(id),
            text: dialogueFor(id, 'safe', context),
          ),
          if (state.playerRadarContestantIds.contains(id))
            Text(
              isEn
                  ? '★ Your radar favorite survived the danger zone.'
                  : '★ Radarındaki isim tehlikeyi atlattı.',
              style: _label(context),
            ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'SEE FAREWELL' : 'VEDAYI GÖR',
            onPressed: () => _go(_Phase.farewell),
          ),
        ],
      ),
    );
  }

  Widget _farewell() {
    final isEn = isAppEnglish(context);
    final id = _result!.eliminatedContestantId;
    return _Page(
      child: Column(
        children: [
          Text(
            '${context.l10n.dayLabel(3)} ${isEn ? "FAREWELL" : "VEDA"}',
            style: _label(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 350,
            child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: _c(id)),
            ),
          ),
          Text(
            _c(id).displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? "Bids farewell to Yıldız Kadro."
                : "Yıldız Kadro'ya veda ediyor.",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          ContestantDialogueBubble(
            contestant: _c(id),
            text: dialogueFor(id, 'farewell', context),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'DAY 3 RESULTS' : '3. GÜN SONUÇLARI',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const Day3ResultsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(child: Text(a, style: _label(context))),
            Text(b, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: MaxWidthContainer(
          maxWidth: 780,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: child,
          ),
        ),
      );
}

TextStyle _label(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.2);
String _formatDescription(Day3FinalCutFormat f, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (f) {
    Day3FinalCutFormat.coverShot => isEn
        ? 'Single frame. Face, posture, and star charisma.'
        : 'Tek kare. Yüz, duruş ve yıldız etkisi.',
    Day3FinalCutFormat.motionShot => isEn
        ? 'Dynamic motion. Rhythm, body control, and stage electricity.'
        : 'Hareketli çekim. Ritim, beden kontrolü ve sahne enerjisi.',
    Day3FinalCutFormat.liveCloseUp => isEn
        ? 'Tight lens. Emotion, micro-expression, and holding the moment.'
        : 'Yakın kamera. Duygu, ifade ve anı taşıma gücü.',
  };
}

String dialogueFor(int id, String scene, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  final style = groupTaskProfiles[id]!.workStyle;
  final options = switch (scene) {
    'safe' => isEn
        ? [
            'One more day.',
            'Now I keep moving forward.',
            'I wasn’t ready to lose this.',
          ]
        : [
            'Bir gün daha.',
            'Şimdi devam ediyorum.',
            'Bunu kaybetmek istemiyordum.',
          ],
    'farewell' => isEn
        ? [
            'I’m proud of how far I came.',
            'I had so much more to show.',
            'At least I went out true to myself.',
          ]
        : [
            'Buraya kadar geldiğim için mutluyum.',
            'Daha fazlasını gösterebilirdim.',
            'En azından kendim gibi çıktım.',
          ],
    'after' => isEn
        ? [
            'I couldn’t have given any more.',
            'I let go of control at one point.',
            'Once the red light turned on, everything shifted.',
          ]
        : [
            'Daha fazlasını yapamazdım.',
            'Bir yerde kontrolü bıraktım.',
            'Kamera açılınca her şey değişti.',
          ],
    'format' => isEn
        ? [
            'I can carry this frame.',
            'We’ll see once the camera rolls.',
            'I will show a different side of myself.',
          ]
        : [
            'Bu kareyi taşıyabilirim.',
            'Kamera açıldığında göreceğiz.',
            'Kendimi başka türlü göstereceğim.',
          ],
    'approach' => isEn
        ? [
            'Exactly what I wanted.',
            'I’m sticking to my game plan.',
            'I’m ready to take the risk.',
          ]
        : [
            'Tam istediğim şey.',
            'Planıma sadık kalacağım.',
            'Risk almaya hazırım.',
          ],
    _ => switch (style) {
        WorkStyle.bold => isEn
            ? [
                'I won’t shrink myself on this stage.',
                'I refuse to play it safe.',
                'I will not back down.',
              ]
            : [
                'Bu sahnede kendimi küçültmeyeceğim.',
                'Güvenli oynamayacağım.',
                'Geri çekilmeyeceğim.',
              ],
        WorkStyle.calm => isEn
            ? [
                'I know exactly what I need to do.',
                'I will stay composed.',
                'One frame is all I need.',
              ]
            : [
                'Ne yapmam gerektiğini biliyorum.',
                'Sakin kalacağım.',
                'Bir kare yeter.',
              ],
        WorkStyle.competitive => isEn
            ? [
                'No way I back down now.',
                'I belong right here.',
                'I’m taking this all the way.',
              ]
            : [
                'Şimdi geri adım atmam.',
                'Burada kalmak istiyorum.',
                'Sonuna kadar gideceğim.',
              ],
        WorkStyle.cameraSavvy => isEn
            ? [
                'I know exactly where the lens is looking.',
                'One frame is plenty for me.',
                'Once the red light hits, I’m ready.',
              ]
            : [
                'Kameranın nereye baktığını biliyorum.',
                'Tek kare bana yeter.',
                'Kamera açılınca hazırım.',
              ],
        WorkStyle.controlled => isEn
            ? [
                'I will not panic.',
                'I stick to the blueprint.',
                'Control remains with me.',
              ]
            : [
                'Panik yapmayacağım.',
                'Planıma sadık kalacağım.',
                'Kontrol bende kalacak.',
              ],
        _ => isEn
            ? [
                'I’ve been waiting for this moment.',
                'I will prove who I am.',
                'I’m ready.',
              ]
            : ['Bu anı bekliyordum.', 'Kendimi göstereceğim.', 'Hazırım.'],
      },
  };
  return options[(id + scene.length) % options.length];
}
