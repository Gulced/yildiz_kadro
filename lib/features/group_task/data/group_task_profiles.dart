import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

const groupTaskProfiles = <int, GroupTaskProfile>{
  1: GroupTaskProfile(
      contestantId: 1,
      primaryRole: GroupRole.stage,
      secondaryRole: GroupRole.allRounder,
      workStyle: WorkStyle.instinctive),
  2: GroupTaskProfile(
      contestantId: 2,
      primaryRole: GroupRole.vocal,
      secondaryRole: GroupRole.stage,
      workStyle: WorkStyle.calm),
  3: GroupTaskProfile(
      contestantId: 3,
      primaryRole: GroupRole.stage,
      secondaryRole: GroupRole.dance,
      workStyle: WorkStyle.observant),
  4: GroupTaskProfile(
      contestantId: 4,
      primaryRole: GroupRole.dance,
      secondaryRole: GroupRole.stage,
      workStyle: WorkStyle.direct),
  5: GroupTaskProfile(
      contestantId: 5,
      primaryRole: GroupRole.stage,
      secondaryRole: GroupRole.dance,
      workStyle: WorkStyle.competitive),
  6: GroupTaskProfile(
      contestantId: 6,
      primaryRole: GroupRole.allRounder,
      secondaryRole: GroupRole.stage,
      workStyle: WorkStyle.social),
  7: GroupTaskProfile(
      contestantId: 7,
      primaryRole: GroupRole.allRounder,
      secondaryRole: GroupRole.vocal,
      workStyle: WorkStyle.bold),
  8: GroupTaskProfile(
      contestantId: 8,
      primaryRole: GroupRole.dance,
      secondaryRole: GroupRole.stage,
      workStyle: WorkStyle.experienced),
  9: GroupTaskProfile(
      contestantId: 9,
      primaryRole: GroupRole.vocal,
      secondaryRole: GroupRole.allRounder,
      workStyle: WorkStyle.controlled),
  10: GroupTaskProfile(
      contestantId: 10,
      primaryRole: GroupRole.stage,
      secondaryRole: GroupRole.allRounder,
      workStyle: WorkStyle.spontaneous),
  11: GroupTaskProfile(
      contestantId: 11,
      primaryRole: GroupRole.stage,
      secondaryRole: GroupRole.dance,
      workStyle: WorkStyle.cameraSavvy),
  12: GroupTaskProfile(
      contestantId: 12,
      primaryRole: GroupRole.vocal,
      secondaryRole: GroupRole.stage,
      workStyle: WorkStyle.chaotic),
  13: GroupTaskProfile(
      contestantId: 13,
      primaryRole: GroupRole.vocal,
      secondaryRole: GroupRole.allRounder,
      workStyle: WorkStyle.protective),
  14: GroupTaskProfile(
      contestantId: 14,
      primaryRole: GroupRole.vocal,
      secondaryRole: GroupRole.allRounder,
      workStyle: WorkStyle.sensitive),
  15: GroupTaskProfile(
      contestantId: 15,
      primaryRole: GroupRole.stage,
      secondaryRole: GroupRole.vocal,
      workStyle: WorkStyle.playful),
};

const day2DraftTiePriority = <int>[
  4,
  7,
  11,
  5,
  15,
  8,
  2,
  14,
  10,
  12,
  3,
  6,
  13,
  1,
  9
];
