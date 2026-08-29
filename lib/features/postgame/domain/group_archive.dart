import 'package:yildiz_kadro/features/postgame/domain/final_group_customization.dart';

class GroupArchiveEntry {
  const GroupArchiveEntry({
    required this.groupName,
    required this.memberIds,
    required this.positions,
    required this.leaderId,
    required this.overallScore,
    required this.mostPopularMemberId,
    required this.completedAt,
  });
  final String groupName;
  final List<int> memberIds;
  final Map<FinalMemberPosition, int> positions;
  final int leaderId;
  final int overallScore;
  final int mostPopularMemberId;
  final DateTime completedAt;
}
