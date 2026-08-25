enum Day6DebutDirection { popPower, performanceUnit, iconGroup }

enum FinalGroupRole {
  mainVocal,
  center,
  performanceLead,
  allRounder,
  starVisual
}

class Day6ContestantResult {
  const Day6ContestantResult({
    required this.contestantId,
    required this.live,
    required this.star,
    required this.growth,
    required this.consistency,
    required this.debutFit,
    required this.finalScore,
    required this.rank,
  });

  final int contestantId;
  final int live;
  final int star;
  final int growth;
  final int consistency;
  final int debutFit;
  final int finalScore;
  final int rank;
}

class LineupBalance {
  const LineupBalance({
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.camera,
    required this.harmony,
  });

  final int vocal;
  final int dance;
  final int stage;
  final int camera;
  final int harmony;
}

class Day6ResultSnapshot {
  const Day6ResultSnapshot({
    required this.direction,
    required this.results,
    required this.rankingIds,
    required this.recommendedLineupIds,
  });

  final Day6DebutDirection direction;
  final Map<int, Day6ContestantResult> results;
  final List<int> rankingIds;
  final List<int> recommendedLineupIds;
}

String day6DirectionLabel(Day6DebutDirection value) => switch (value) {
      Day6DebutDirection.popPower => 'POP POWER',
      Day6DebutDirection.performanceUnit => 'PERFORMANCE UNIT',
      Day6DebutDirection.iconGroup => 'ICON GROUP',
    };

String finalRoleLabel(FinalGroupRole value) => switch (value) {
      FinalGroupRole.mainVocal => 'MAIN VOCAL',
      FinalGroupRole.center => 'CENTER',
      FinalGroupRole.performanceLead => 'PERFORMANCE LEAD',
      FinalGroupRole.allRounder => 'ALL-ROUNDER',
      FinalGroupRole.starVisual => 'STAR / VISUAL',
    };
