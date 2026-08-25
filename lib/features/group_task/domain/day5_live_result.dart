enum Day5BroadcastDirection { bigStage, closeCamera, storyNight }

class Day5ContestantResult {
  const Day5ContestantResult(
      {required this.contestantId,
      required this.liveStage,
      required this.cameraTalk,
      required this.fanConnect,
      required this.broadcastFitModifier,
      required this.rawLiveScore,
      required this.scoreWithoutDirection,
      required this.rank});
  final int contestantId;
  final int liveStage;
  final int cameraTalk;
  final int fanConnect;
  final int broadcastFitModifier;
  final double rawLiveScore;
  final double scoreWithoutDirection;
  final int rank;
  int get liveScore => rawLiveScore.round().clamp(0, 100);
  bool get top3 => rank <= 3;
  bool get finalist => rank <= 7;
}

class Day5ResultSnapshot {
  const Day5ResultSnapshot(
      {required this.direction,
      required this.results,
      required this.rankingIds,
      required this.finalistIds,
      required this.eliminatedIds,
      required this.playerChangedCut});
  final Day5BroadcastDirection direction;
  final Map<int, Day5ContestantResult> results;
  final List<int> rankingIds;
  final List<int> finalistIds;
  final List<int> eliminatedIds;
  final bool playerChangedCut;
}

String day5DirectionLabel(Day5BroadcastDirection d) => switch (d) {
      Day5BroadcastDirection.bigStage => 'BÜYÜK SAHNE',
      Day5BroadcastDirection.closeCamera => 'YAKIN KAMERA',
      Day5BroadcastDirection.storyNight => 'HİKÂYE GECESİ'
    };
