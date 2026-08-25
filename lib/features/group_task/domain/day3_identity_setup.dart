enum Day3Concept { popIcon, highFashion, romanticStar, rebelEdge, dreamyCinema }

enum Day3CreativeDirection { sharpenIdentity, surprise, ownCamera }

class Day3SelfDirectionModifiers {
  const Day3SelfDirectionModifiers(
      {this.identity = 0,
      this.styling = 0,
      this.camera = 0,
      this.performance = 0,
      this.originality = 0,
      this.consistency = 0});
  final int identity;
  final int styling;
  final int camera;
  final int performance;
  final int originality;
  final int consistency;
}

class Day3IdentityAllocation {
  const Day3IdentityAllocation(
      {required this.conceptByContestantId,
      required this.conceptFitByContestantId,
      required this.selfDirectionByContestantId});
  final Map<int, Day3Concept> conceptByContestantId;
  final Map<int, int> conceptFitByContestantId;
  final Map<int, Day3SelfDirectionModifiers> selfDirectionByContestantId;
}

class Day3IdentitySetupSnapshot {
  const Day3IdentitySetupSnapshot(
      {required this.allocation,
      required this.creativeDirectionByContestantId,
      required this.creativeModifierByContestantId,
      required this.stylingSupportContestantIds});
  final Day3IdentityAllocation allocation;
  final Map<int, Day3CreativeDirection> creativeDirectionByContestantId;
  final Map<int, int> creativeModifierByContestantId;
  final List<int> stylingSupportContestantIds;
}
