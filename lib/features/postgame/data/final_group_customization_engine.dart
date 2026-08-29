import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/postgame/domain/final_group_customization.dart';
import 'package:yildiz_kadro/features/postgame/data/group_tag_normalizer.dart';

Map<int, List<String>> calculateAutomaticGroupTags(
  GameState state,
  Map<FinalMemberPosition, int> positions,
) {
  final ids = state.playerFinalLineupIds;
  final tags = {for (final id in ids) id: <String>[]};
  final youngest = ids.reduce((a, b) => _c(a).age <= _c(b).age ? a : b);
  final eldest = ids.reduce((a, b) => _c(a).age >= _c(b).age ? a : b);
  tags[youngest]!.add('MAKNAE');
  tags[eldest]!.add('ELDEST');
  int aceScore(int id) => (_c(id).vocal +
          _c(id).dance +
          _c(id).stage +
          state.day6ResultSnapshot!.results[id]!.consistency)
      .round();
  final ace = ids.reduce((a, b) => aceScore(a) >= aceScore(b) ? a : b);
  tags[ace]!.add('ACE');
  int visualScore(int id) =>
      state.day3IconResultSnapshot!.results[id]!.camera +
      state.day3IconResultSnapshot!.results[id]!.identity +
      state.day5ResultSnapshot!.results[id]!.fanConnect;
  final visual = ids.reduce((a, b) => visualScore(a) >= visualScore(b) ? a : b);
  tags[visual]!.add('IMAGE MEMBER');
  final moodCandidates = ids.where((id) => {WorkStyle.playful, WorkStyle.social}
      .contains(groupTaskProfiles[id]!.workStyle));
  if (moodCandidates.isNotEmpty) {
    tags[moodCandidates.first]!.add('MOOD MAKER');
  }
  for (final entry in positions.entries) {
    if ({FinalMemberPosition.mainVocal, FinalMemberPosition.leadVocal}
        .contains(entry.key)) {
      tags[entry.value]!.add('VOCAL LINE');
    }
    if ({FinalMemberPosition.mainDancer, FinalMemberPosition.leadDancer}
        .contains(entry.key)) {
      tags[entry.value]!.add('DANCE LINE');
    }
  }
  return freezeAutomaticGroupTags(tags);
}

Map<int, List<String>> freezeAutomaticGroupTags(
  Map<int, List<String>> tags,
) =>
    normalizeAutomaticGroupTags(tags);

Contestant _c(int id) =>
    contestantSeedData.firstWhere((value) => value.id == id);
