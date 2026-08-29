import 'package:flutter/foundation.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/last_chance/domain/last_chance_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_draft_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_rehearsal.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_jury_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_duel_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_icon_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_final_cut_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day5_live_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day6_final_result.dart';
import 'package:yildiz_kadro/features/postgame/domain/final_group_customization.dart';
import 'package:yildiz_kadro/features/postgame/domain/group_archive.dart';
import 'package:yildiz_kadro/features/postgame/data/group_tag_normalizer.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/producer/data/story_event_engine.dart';
import 'package:yildiz_kadro/features/producer/domain/contestant_social_state.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';
import 'package:yildiz_kadro/features/producer/domain/performance_aftermath.dart';

class GameState extends ChangeNotifier {
  GameState({int? seasonSeed})
      : _seasonSeed = seasonSeed ?? DateTime.now().microsecondsSinceEpoch {
    _resetLivingSeason();
  }

  int _seasonSeed;
  Map<int, ContestantSocialState> _contestantSocialStates = const {};
  Map<int, Map<int, int>> _contestantRelationships = const {};
  List<StoryEventRecord> _eventHistory = const [];
  final Set<String> _seenEventFamilies = {};
  List<int> _playerRadarContestantIds = const [];
  bool _evaluation1Completed = false;
  Map<int, EvaluationResult> _evaluation1Results = const {};
  int? _producerSaveContestantId;
  int? _jurySaveContestantId;
  List<int> _lastChanceContestantIds = const [];
  bool _juryDecision1Completed = false;
  int? _lastChanceCoachContestantId;
  Map<int, LastChanceResult> _lastChanceResults = const {};
  final List<int> _eliminatedContestantIds = [];
  bool _lastChance1Completed = false;
  int? _day2CaptainAId;
  int? _day2CaptainBId;
  List<int> _day2TeamAIds = const [];
  List<int> _day2TeamBIds = const [];
  List<Day2DraftEvent> _day2TeamDraftEvents = const [];
  int? _day2LastPickedContestantId;
  TeamAverages? _day2TeamAAverages;
  TeamAverages? _day2TeamBAverages;
  bool _day2TeamFormationCompleted = false;
  Day2RehearsalSetup? _day2RehearsalSetup;
  String? _day2PlayerInterventionTeamId;
  Day2RehearsalOutcome? _day2RehearsalOutcome;
  bool _day2RehearsalCompleted = false;
  Day2GroupPerformanceSnapshot? _day2GroupPerformanceSnapshot;
  int? _day2StarImmunityContestantId;
  List<int> _day2JuryRiskContestantIds = const [];
  bool _day2GroupPerformanceCompleted = false;
  Day2JuryResultSnapshot? _day2JuryResultSnapshot;
  bool _day2JuryTableCompleted = false;
  Day2DuelResultSnapshot? _day2DuelResultSnapshot;
  bool _day2DuelCompleted = false;
  bool _day2Completed = false;
  Day3IdentityAllocation? _day3IdentityAllocation;
  Day3IdentitySetupSnapshot? _day3IdentitySetupSnapshot;
  bool _day3IdentitySetupCompleted = false;
  Day3IconResultSnapshot? _day3IconResultSnapshot;
  Day3FinalCutResultSnapshot? _day3FinalCutResultSnapshot;
  bool _day3Completed = false;
  Day4RoomAllocation? _day4RoomAllocation;
  Day4Room? _day4MentorRoom;
  Day4ResultSnapshot? _day4ResultSnapshot;
  bool _day4Completed = false;
  Day5ResultSnapshot? _day5ResultSnapshot;
  bool _day5Completed = false;
  Day6DebutDirection? _day6DebutDirection;
  Day6ResultSnapshot? _day6ResultSnapshot;
  List<int> _playerFinalLineupIds = const [];
  List<int> _finalistsOutsideDebutLineupIds = const [];
  LineupBalance? _finalLineupBalance;
  Map<FinalGroupRole, int> _suggestedFinalRoles = const {};
  bool _day6FinalLineupConfirmed = false;
  Map<FinalMemberPosition, int> _finalMemberPositions = const {};
  int? _finalLeaderId;
  Map<int, MemberColor> _finalMemberColors = const {};
  Map<int, List<String>> _automaticGroupTags = const {};
  bool _finalRevealCompleted = false;
  bool _seasonCompleted = false;
  String? _groupName;
  final List<GroupArchiveEntry> _groupArchive = [];
  final Map<String, PerformanceAftermath> _performanceAftermath = {};
  final Set<String> _seenMissionBriefings = {};

  List<int> get playerRadarContestantIds =>
      List.unmodifiable(_playerRadarContestantIds);
  bool get evaluation1Completed => _evaluation1Completed;
  Map<int, EvaluationResult> get evaluation1Results =>
      Map.unmodifiable(_evaluation1Results);
  int? get producerSaveContestantId => _producerSaveContestantId;
  int? get jurySaveContestantId => _jurySaveContestantId;
  List<int> get lastChanceContestantIds =>
      List.unmodifiable(_lastChanceContestantIds);
  bool get juryDecision1Completed => _juryDecision1Completed;
  int? get lastChanceCoachContestantId => _lastChanceCoachContestantId;
  Map<int, LastChanceResult> get storedLastChanceResults =>
      Map.unmodifiable(_lastChanceResults);
  List<int> get eliminatedContestantIds =>
      List.unmodifiable(_eliminatedContestantIds);
  bool get lastChance1Completed => _lastChance1Completed;
  int get activeContestantCount => 15 - _eliminatedContestantIds.length;
  int? get day2CaptainAId => _day2CaptainAId;
  int? get day2CaptainBId => _day2CaptainBId;
  List<int> get day2TeamAIds => List.unmodifiable(_day2TeamAIds);
  List<int> get day2TeamBIds => List.unmodifiable(_day2TeamBIds);
  List<Day2DraftEvent> get day2TeamDraftEvents =>
      List.unmodifiable(_day2TeamDraftEvents);
  int? get day2LastPickedContestantId => _day2LastPickedContestantId;
  TeamAverages? get day2TeamAAverages => _day2TeamAAverages;
  TeamAverages? get day2TeamBAverages => _day2TeamBAverages;
  bool get day2TeamFormationCompleted => _day2TeamFormationCompleted;
  Day2RehearsalSetup? get day2RehearsalSetup => _day2RehearsalSetup;
  String? get day2PlayerInterventionTeamId => _day2PlayerInterventionTeamId;
  Day2RehearsalOutcome? get day2RehearsalOutcome => _day2RehearsalOutcome;
  bool get day2RehearsalCompleted => _day2RehearsalCompleted;
  Day2GroupPerformanceSnapshot? get day2GroupPerformanceSnapshot =>
      _day2GroupPerformanceSnapshot;
  int? get day2StarImmunityContestantId => _day2StarImmunityContestantId;
  List<int> get day2InitialRiskContestantIds => List.unmodifiable(
        _day2GroupPerformanceSnapshot?.initialRiskIds ?? const <int>[],
      );
  List<int> get day2JuryRiskContestantIds =>
      List.unmodifiable(_day2JuryRiskContestantIds);
  bool get day2GroupPerformanceCompleted => _day2GroupPerformanceCompleted;
  Day2JuryResultSnapshot? get day2JuryResultSnapshot => _day2JuryResultSnapshot;
  int? get day2JurySavedContestantId =>
      _day2JuryResultSnapshot?.savedContestantId;
  List<int> get day2DuelContestantIds => List.unmodifiable(
        _day2JuryResultSnapshot?.duelContestantIds ?? const <int>[],
      );
  bool get day2JuryTableCompleted => _day2JuryTableCompleted;
  Day2DuelResultSnapshot? get day2DuelResultSnapshot => _day2DuelResultSnapshot;
  int? get day2DuelWinnerContestantId =>
      _day2DuelResultSnapshot?.winnerContestantId;
  int? get day2EliminatedContestantId =>
      _day2DuelResultSnapshot?.eliminatedContestantId;
  bool get day2DuelCompleted => _day2DuelCompleted;
  bool get day2Completed => _day2Completed;
  Day3IdentityAllocation? get day3IdentityAllocation => _day3IdentityAllocation;
  Day3IdentitySetupSnapshot? get day3IdentitySetupSnapshot =>
      _day3IdentitySetupSnapshot;
  bool get day3IdentitySetupCompleted => _day3IdentitySetupCompleted;
  Day3IconResultSnapshot? get day3IconResultSnapshot => _day3IconResultSnapshot;
  List<int> get day3FinalCutContestantIds => List.unmodifiable(
      _day3IconResultSnapshot?.finalCutContestantIds ?? const <int>[]);
  Day3FinalCutResultSnapshot? get day3FinalCutResultSnapshot =>
      _day3FinalCutResultSnapshot;
  bool get day3Completed => _day3Completed;
  Day4RoomAllocation? get day4RoomAllocation => _day4RoomAllocation;
  Day4Room? get day4MentorRoom => _day4MentorRoom;
  Day4ResultSnapshot? get day4ResultSnapshot => _day4ResultSnapshot;
  bool get day4Completed => _day4Completed;
  Day5ResultSnapshot? get day5ResultSnapshot => _day5ResultSnapshot;
  List<int> get day5FinalistIds =>
      List.unmodifiable(_day5ResultSnapshot?.finalistIds ?? const <int>[]);
  List<int> get day5EliminatedContestantIds =>
      List.unmodifiable(_day5ResultSnapshot?.eliminatedIds ?? const <int>[]);
  bool get day5Completed => _day5Completed;
  Day6DebutDirection? get day6DebutDirection => _day6DebutDirection;
  Day6ResultSnapshot? get day6ResultSnapshot => _day6ResultSnapshot;
  List<int> get recommendedFinalLineupIds => List.unmodifiable(
      _day6ResultSnapshot?.recommendedLineupIds ?? const <int>[]);
  List<int> get playerFinalLineupIds =>
      List.unmodifiable(_playerFinalLineupIds);
  List<int> get finalistsOutsideDebutLineupIds =>
      List.unmodifiable(_finalistsOutsideDebutLineupIds);
  LineupBalance? get finalLineupBalance => _finalLineupBalance;
  Map<FinalGroupRole, int> get suggestedFinalRoles =>
      Map.unmodifiable(_suggestedFinalRoles);
  bool get day6FinalLineupConfirmed => _day6FinalLineupConfirmed;
  Map<FinalMemberPosition, int> get finalMemberPositions =>
      Map.unmodifiable(_finalMemberPositions);
  int? get finalLeaderId => _finalLeaderId;
  Map<int, MemberColor> get finalMemberColors =>
      Map.unmodifiable(_finalMemberColors);
  Map<int, List<String>> get automaticGroupTags =>
      normalizeAutomaticGroupTags(_automaticGroupTags);
  bool get finalRevealCompleted => _finalRevealCompleted;
  bool get seasonCompleted => _seasonCompleted;
  String? get groupName => _groupName;
  List<GroupArchiveEntry> get groupArchive => List.unmodifiable(_groupArchive);
  PerformanceAftermath? performanceAftermath(String stageId) =>
      _performanceAftermath[stageId];
  int get seasonSeed => _seasonSeed;
  Map<int, ContestantSocialState> get contestantSocialStates =>
      Map.unmodifiable(_contestantSocialStates);
  List<StoryEventRecord> get eventHistory => List.unmodifiable(_eventHistory);
  Set<String> get seenEventFamilies => Set.unmodifiable(_seenEventFamilies);

  StoryEventRecord? storyEventForDay(int day) {
    for (final record in _eventHistory) {
      if (record.day == day) return record;
    }
    return null;
  }

  bool hasSeenMissionBriefing(String stageId) =>
      _seenMissionBriefings.contains(stageId);

  void markMissionBriefingSeen(String stageId) {
    if (_seenMissionBriefings.add(stageId)) notifyListeners();
  }

  ContestantSocialState socialStateFor(int contestantId) =>
      _contestantSocialStates[contestantId]!;

  int relationshipBetween(int firstId, int secondId) =>
      _contestantRelationships[firstId]?[secondId] ?? 50;

  StoryEventRecord ensureStoryEvent(int day) {
    final existing = _eventHistory.where((record) => record.day == day);
    if (existing.isNotEmpty) return existing.first;
    final activeIds = contestantSeedData
        .map((contestant) => contestant.id)
        .where((id) => !_eliminatedContestantIds.contains(id))
        .toList();
    final event = createStoryEvent(
      seasonSeed: _seasonSeed,
      day: day,
      eligibleIds: activeIds,
      seenEventIds: _eventHistory
          .map((record) => record.event.id.split('_d').first)
          .toSet(),
      socialStates: _contestantSocialStates,
      relationships: _contestantRelationships,
    );
    final record = StoryEventRecord(day: day, event: event);
    _eventHistory = List.unmodifiable([..._eventHistory, record]);
    _seenEventFamilies.add(event.family.name);
    notifyListeners();
    return record;
  }

  void resolveStoryEvent({required int day, required String choiceId}) {
    final index = _eventHistory.indexWhere((record) => record.day == day);
    if (index < 0) throw StateError('Önce hikâye olayı oluşturulmalı.');
    final record = _eventHistory[index];
    if (record.choiceId != null) return;
    final choice =
        record.event.choices.firstWhere((value) => value.id == choiceId);
    final before = {
      for (final id in record.event.contestantIds)
        id: _storyMetricSnapshot(_contestantSocialStates[id]!),
    };
    for (final id in record.event.contestantIds) {
      final current = _contestantSocialStates[id]!;
      final effects = adjustedStoryEffects(choice: choice, contestantId: id);
      _contestantSocialStates = Map.unmodifiable({
        ..._contestantSocialStates,
        id: current.apply(
          popularity: effects['popularity'] ?? 0,
          buzz: effects['buzz'] ?? 0,
          followers: effects['followers'] ?? 0,
          morale: effects['morale'] ?? 0,
          confidence: effects['confidence'] ?? 0,
          professionalism: effects['professionalism'] ?? 0,
          energy: effects['energy'] ?? 0,
          preparation: effects['preparation'] ?? 0,
          vocalCoachImpression: effects['vocalCoach'] ?? 0,
          danceCoachImpression: effects['danceCoach'] ?? 0,
          day: day,
          reason: record.event.title,
          experienceXp: 12,
        )
      });
    }
    if (record.event.contestantIds.length == 2) {
      final firstEffects = adjustedStoryEffects(
        choice: choice,
        contestantId: record.event.contestantIds.first,
      );
      _changeRelationship(record.event.contestantIds[0],
          record.event.contestantIds[1], firstEffects['relationship'] ?? 0);
    }
    final records = [..._eventHistory];
    final after = {
      for (final id in record.event.contestantIds)
        id: _storyMetricSnapshot(_contestantSocialStates[id]!),
    };
    records[index] = record.resolve(choiceId, before: before, after: after);
    _eventHistory = List.unmodifiable(records);
    notifyListeners();
  }

  Map<int, Map<String, int>> previewStoryChoice(
    StoryEvent event,
    StoryChoice choice,
  ) =>
      Map.unmodifiable({
        for (final id in event.contestantIds)
          id: adjustedStoryEffects(choice: choice, contestantId: id),
      });

  Map<String, int> _storyMetricSnapshot(ContestantSocialState social) => {
        'motivation': social.motivation,
        'popularity': social.popularity,
        'buzz': social.buzz,
        'confidence': social.confidence,
        'energy': social.energy,
        'preparation': social.preparation,
        'professionalism': social.professionalism,
        'followers': social.followers,
      };

  void _changeRelationship(int first, int second, int delta) {
    final next = _contestantRelationships
        .map((id, values) => MapEntry(id, Map<int, int>.from(values)));
    next[first]![second] = ((next[first]![second] ?? 50) + delta).clamp(0, 100);
    next[second]![first] = next[first]![second]!;
    _contestantRelationships = Map<int, Map<int, int>>.unmodifiable(next
        .map((id, values) => MapEntry(id, Map<int, int>.unmodifiable(values))));
  }

  void _resetLivingSeason() {
    _eventHistory = const [];
    _seenEventFamilies.clear();
    _contestantSocialStates = Map.unmodifiable({
      for (final contestant in contestantSeedData)
        contestant.id: ContestantSocialState(
          popularity: contestant.popularity,
          buzz: 35 + contestant.stage ~/ 5,
          followers: 12000 + contestant.popularity * 1250,
          morale: contestant.initialMotivation,
          confidence: 55 + contestant.stage ~/ 3,
          professionalism: 58 + (contestant.vocal + contestant.dance) ~/ 6,
          energy: 78,
          preparation: 65,
          vocalCoachImpression: contestant.vocal,
          danceCoachImpression: contestant.dance,
          followerHistory: [
            FollowerSnapshot(
                day: 0,
                count: 12000 + contestant.popularity * 1250,
                reason: 'Sezon başlangıcı')
          ],
        ),
    });
    _contestantRelationships = Map<int, Map<int, int>>.unmodifiable({
      for (final contestant in contestantSeedData)
        contestant.id: Map<int, int>.unmodifiable({
          for (final other in contestantSeedData)
            if (other.id != contestant.id) other.id: 50
        }),
    });
  }

  void savePlayerRadar(Iterable<int> contestantIds) {
    final ids = contestantIds.toSet().toList(growable: false);
    if (ids.length != 5) {
      throw ArgumentError.value(
          ids, 'contestantIds', 'Tam olarak 5 kişi seçilmeli.');
    }
    _playerRadarContestantIds = ids;
    notifyListeners();
  }

  void completeEvaluation1(Map<int, EvaluationResult> results) {
    if (results.length != 15) {
      throw ArgumentError.value(results, 'results', '15 sonuç bulunmalı.');
    }
    _evaluation1Results = Map.unmodifiable(results);
    _evaluation1Completed = true;
    _applyPerformanceImpact(
      stageId: 'evaluation_1',
      scores:
          results.map((id, result) => MapEntry(id, result.overall.toDouble())),
      reason: 'İlk sahne testi izleyicinin dikkatini değiştirdi.',
      xpBase: 30,
    );
    notifyListeners();
  }

  void completeJuryDecision1({
    required int producerSaveContestantId,
    required int jurySaveContestantId,
    required Iterable<int> lastChanceContestantIds,
  }) {
    if (_juryDecision1Completed) return;
    final lastChanceIds =
        lastChanceContestantIds.toSet().toList(growable: false);
    if (lastChanceIds.length != 3 ||
        lastChanceIds.contains(producerSaveContestantId) ||
        lastChanceIds.contains(jurySaveContestantId)) {
      throw ArgumentError('Jüri kararı geçersiz.');
    }
    _producerSaveContestantId = producerSaveContestantId;
    _jurySaveContestantId = jurySaveContestantId;
    _lastChanceContestantIds = lastChanceIds;
    _juryDecision1Completed = true;
    notifyListeners();
  }

  void lockLastChanceCoach(int contestantId) {
    if (_lastChanceCoachContestantId != null) return;
    if (!_lastChanceContestantIds.contains(contestantId)) {
      throw ArgumentError.value(contestantId, 'contestantId');
    }
    _lastChanceCoachContestantId = contestantId;
    notifyListeners();
  }

  void completeLastChance1({
    required Map<int, LastChanceResult> results,
    required int eliminatedContestantId,
  }) {
    if (_lastChance1Completed) return;
    if (_lastChanceCoachContestantId == null ||
        results.length != 3 ||
        !results.containsKey(eliminatedContestantId)) {
      throw ArgumentError('Son Şans sonucu geçersiz.');
    }
    _lastChanceResults = Map.unmodifiable(results);
    if (!_eliminatedContestantIds.contains(eliminatedContestantId)) {
      _eliminatedContestantIds.add(eliminatedContestantId);
    }
    _lastChance1Completed = true;
    notifyListeners();
  }

  void completeDay2TeamFormation(Day2DraftResult result) {
    if (_day2TeamFormationCompleted) return;
    final allIds = {...result.teamAIds, ...result.teamBIds};
    if (result.teamAIds.length != 7 ||
        result.teamBIds.length != 7 ||
        allIds.length != 14 ||
        allIds.any(_eliminatedContestantIds.contains) ||
        !result.teamAIds.contains(result.captainAId) ||
        !result.teamBIds.contains(result.captainBId)) {
      throw ArgumentError('Day 2 takım sonucu geçersiz.');
    }
    _day2CaptainAId = result.captainAId;
    _day2CaptainBId = result.captainBId;
    _day2TeamAIds = List.unmodifiable(result.teamAIds);
    _day2TeamBIds = List.unmodifiable(result.teamBIds);
    _day2TeamDraftEvents = List.unmodifiable(result.events);
    _day2LastPickedContestantId = result.lastPickedContestantId;
    _day2TeamAAverages = result.teamAAverages;
    _day2TeamBAverages = result.teamBAverages;
    _day2TeamFormationCompleted = true;
    notifyListeners();
  }

  void initializeDay2Rehearsal(Day2RehearsalSetup setup) {
    if (_day2RehearsalSetup != null) return;
    if (!_day2TeamFormationCompleted) {
      throw StateError('Takımlar kurulmadan prova başlatılamaz.');
    }
    _day2RehearsalSetup = setup;
    notifyListeners();
  }

  void lockDay2PlayerInterventionTeam(String teamId) {
    if (_day2PlayerInterventionTeamId != null) return;
    if (teamId != 'A' && teamId != 'B' && teamId != 'BOTH') {
      throw ArgumentError.value(teamId, 'teamId');
    }
    _day2PlayerInterventionTeamId = teamId;
    notifyListeners();
  }

  void completeDay2Rehearsal(Day2RehearsalOutcome outcome) {
    if (_day2RehearsalCompleted) return;
    if (_day2RehearsalSetup == null ||
        _day2PlayerInterventionTeamId != outcome.playerInterventionTeamId) {
      throw StateError('Prova setup verisi bulunamadı.');
    }
    _day2RehearsalOutcome = outcome;
    final choices = outcome.playerChoicesByTeam.isNotEmpty
        ? outcome.playerChoicesByTeam
        : {
            outcome.playerInterventionTeamId: outcome.playerChoice,
            outcome.captainResolutionTeamId: outcome.captainChoice,
          };
    for (final entry in choices.entries) {
      final crisis = entry.key == 'A'
          ? _day2RehearsalSetup!.teamACrisis
          : _day2RehearsalSetup!.teamBCrisis;
      final choice = entry.value;
      final participants = <int>{
        crisis.primaryContestantId,
        if (crisis.secondaryContestantId != null) crisis.secondaryContestantId!,
      };
      for (final id in participants) {
        final social = _contestantSocialStates[id]!;
        _contestantSocialStates = Map.unmodifiable({
          ..._contestantSocialStates,
          id: social.apply(
            morale: choice.harmonyModifier - 1,
            confidence: choice.energyModifier > 0 ? 2 : 0,
            professionalism: choice.readinessModifier > 2 ? 2 : 0,
            experienceXp: 20,
          ),
        });
      }
      if (participants.length == 2) {
        _changeRelationship(
          participants.first,
          participants.last,
          choice.harmonyModifier,
        );
      }
    }
    _day2RehearsalCompleted = true;
    _applyPerformanceImpact(
      stageId: 'day2_rehearsal',
      scores: {
        for (final id in _day2TeamAIds)
          id: outcome.teamAFinalMetrics.readiness.toDouble(),
        for (final id in _day2TeamBIds)
          id: outcome.teamBFinalMetrics.readiness.toDouble(),
      },
      reason: 'Zorlu prova deneyim ve momentum kazandırdı.',
      xpBase: 35,
    );
    notifyListeners();
  }

  void initializeDay2GroupPerformance(
    Day2GroupPerformanceSnapshot snapshot,
  ) {
    if (_day2GroupPerformanceSnapshot != null) return;
    if (!_day2RehearsalCompleted) {
      throw StateError('Prova tamamlanmadan grup performansı başlatılamaz.');
    }
    _day2GroupPerformanceSnapshot = snapshot;
    _applyPerformanceImpact(
      stageId: 'day2_group_stage',
      scores: snapshot.individualResults
          .map((id, result) => MapEntry(id, result.overall.toDouble())),
      reason: 'Grup sahnesindeki görünürlük fan ilgisine yansıdı.',
      xpBase: 45,
    );
    notifyListeners();
  }

  void completeDay2GroupPerformance({required int immunityContestantId}) {
    if (_day2GroupPerformanceCompleted) return;
    final snapshot = _day2GroupPerformanceSnapshot;
    if (snapshot == null ||
        !snapshot.initialRiskIds.contains(immunityContestantId)) {
      throw ArgumentError.value(immunityContestantId, 'immunityContestantId');
    }
    final juryRisk = snapshot.initialRiskIds
        .where((id) => id != immunityContestantId)
        .toList(growable: false);
    if (juryRisk.length != 3 || juryRisk.toSet().length != 3) {
      throw StateError('Day 2 jüri risk üçlüsü geçersiz.');
    }
    _day2StarImmunityContestantId = immunityContestantId;
    _day2JuryRiskContestantIds = List.unmodifiable(juryRisk);
    _day2GroupPerformanceCompleted = true;
    notifyListeners();
  }

  void completeDay2JuryTable(Day2JuryResultSnapshot snapshot) {
    if (_day2JuryTableCompleted) return;
    final juryRisk = _day2JuryRiskContestantIds.toSet();
    final duelIds = snapshot.duelContestantIds.toSet();
    final winningTeamIds = _day2GroupPerformanceSnapshot!.winningTeamId == 'A'
        ? _day2TeamAIds.toSet()
        : _day2TeamBIds.toSet();
    final valid = _day2GroupPerformanceCompleted &&
        juryRisk.length == 3 &&
        snapshot.evaluations.keys.toSet().containsAll(juryRisk) &&
        juryRisk.contains(snapshot.savedContestantId) &&
        duelIds.length == 2 &&
        juryRisk.containsAll(duelIds) &&
        !duelIds.contains(snapshot.savedContestantId) &&
        !duelIds.any(_eliminatedContestantIds.contains) &&
        !juryRisk.contains(_day2StarImmunityContestantId) &&
        juryRisk.intersection(winningTeamIds).isEmpty;
    if (!valid) {
      debugPrint('Day 2 Jury Table validation failed.');
      throw StateError('Day 2 Jüri Masası sonucu geçersiz.');
    }
    _day2JuryResultSnapshot = snapshot;
    _day2JuryTableCompleted = true;
    notifyListeners();
  }

  void completeDay2Duel(Day2DuelResultSnapshot snapshot) {
    if (_day2DuelCompleted) return;
    final pair = day2DuelContestantIds.toSet();
    final valid = _day2JuryTableCompleted &&
        pair.length == 2 &&
        snapshot.results.keys.toSet().containsAll(pair) &&
        pair.contains(snapshot.winnerContestantId) &&
        pair.contains(snapshot.eliminatedContestantId) &&
        snapshot.winnerContestantId != snapshot.eliminatedContestantId &&
        !pair.contains(day2JurySavedContestantId) &&
        !pair.contains(_day2StarImmunityContestantId) &&
        !pair.any(_eliminatedContestantIds.contains);
    if (!valid) {
      debugPrint('Day 2 Duel validation failed.');
      throw StateError('Day 2 Düello sonucu geçersiz.');
    }
    _day2DuelResultSnapshot = snapshot;
    _applyPerformanceImpact(
      stageId: 'day2_duel',
      scores: snapshot.results
          .map((id, result) => MapEntry(id, result.finalScore.toDouble())),
      reason: 'Bire bir düello izleyici ilgisini keskin biçimde değiştirdi.',
      xpBase: 55,
    );
    _eliminatedContestantIds.add(snapshot.eliminatedContestantId);
    if (_eliminatedContestantIds.toSet().length != 2 ||
        activeContestantCount != 13) {
      throw StateError('Day 2 eleme sayımı geçersiz.');
    }
    _day2DuelCompleted = true;
    _day2Completed = true;
    notifyListeners();
  }

  void _applyPerformanceImpact({
    required String stageId,
    required Map<int, double> scores,
    required String reason,
    required int xpBase,
  }) {
    if (_performanceAftermath.containsKey(stageId)) return;
    final changes = <PerformanceChange>[];
    for (final entry in scores.entries) {
      final before = _contestantSocialStates[entry.key];
      if (before == null) continue;
      final score = entry.value.round().clamp(0, 100);
      final popularity = score >= 88
          ? 4
          : score >= 78
              ? 2
              : score < 62
                  ? -1
                  : 0;
      final motivation = score >= 84
          ? 5
          : score >= 72
              ? 2
              : score < 60
                  ? -4
                  : -1;
      final followers = 1200 + score * 135 + (popularity.clamp(0, 9) * 850);
      final after = before.apply(
        popularity: popularity,
        morale: motivation,
        confidence: score >= 80
            ? 3
            : score < 60
                ? -2
                : 1,
        followers: followers,
        experienceXp: xpBase + score ~/ 6,
        day: _currentDay,
        reason: reason,
      );
      _contestantSocialStates = Map.unmodifiable({
        ..._contestantSocialStates,
        entry.key: after,
      });
      changes.add(PerformanceChange(
        contestantId: entry.key,
        before: before,
        after: after,
        reason: _impactReason(score, reason),
      ));
    }
    _performanceAftermath[stageId] = PerformanceAftermath(
      stageId: stageId,
      changes: List.unmodifiable(changes),
    );
  }

  int get _currentDay => _day5Completed
      ? 6
      : _day4Completed
          ? 5
          : _day3Completed
              ? 4
              : _day2Completed
                  ? 3
                  : _lastChance1Completed
                      ? 2
                      : 1;

  String _impactReason(int score, String fallback) => score >= 88
      ? 'Sahnedeki güçlü anı sosyal medyada karşılık buldu.'
      : score < 62
          ? 'Zorlanan performans motivasyonunu etkiledi; deneyim kazandırdı.'
          : fallback;

  void initializeDay3Identity(Day3IdentityAllocation allocation) {
    if (_day3IdentityAllocation != null) return;
    final activeIds = List.generate(15, (index) => index + 1)
        .where((id) => !_eliminatedContestantIds.contains(id))
        .toSet();
    final concepts = allocation.conceptByContestantId;
    final valid = _day2Completed &&
        activeIds.length == 13 &&
        concepts.length == 13 &&
        concepts.keys.toSet().containsAll(activeIds) &&
        !concepts.keys.any(_eliminatedContestantIds.contains) &&
        Day3Concept.values.every(
          (concept) =>
              concepts.values.where((value) => value == concept).length <= 4,
        );
    if (!valid) throw StateError('Day 3 konsept dağılımı geçersiz.');
    _day3IdentityAllocation = allocation;
    notifyListeners();
  }

  void completeDay3IdentitySetup(Day3IdentitySetupSnapshot snapshot) {
    if (_day3IdentitySetupCompleted) return;
    final directed = snapshot.creativeDirectionByContestantId.keys.toSet();
    final valid = _day3IdentityAllocation != null &&
        identical(snapshot.allocation, _day3IdentityAllocation) &&
        directed.length == 3 &&
        snapshot.stylingSupportContestantIds.toSet().containsAll(directed) &&
        snapshot.stylingSupportContestantIds.length == 3 &&
        directed
            .every(_day3IdentityAllocation!.conceptByContestantId.containsKey);
    if (!valid) throw StateError('Day 3 yaratıcı planı geçersiz.');
    _day3IdentitySetupSnapshot = snapshot;
    _day3IdentitySetupCompleted = true;
    notifyListeners();
  }

  void completeDay3IconTest(Day3IconResultSnapshot snapshot) {
    if (_day3IconResultSnapshot != null) return;
    final active = List.generate(15, (i) => i + 1)
        .where((id) => !_eliminatedContestantIds.contains(id))
        .toSet();
    final valid = _day3IdentitySetupCompleted &&
        snapshot.results.length == 13 &&
        snapshot.results.keys.toSet().containsAll(active) &&
        snapshot.bottom4Ids.toSet().length == 4 &&
        snapshot.jurySavedIds.toSet().length == 2 &&
        snapshot.finalCutContestantIds.toSet().length == 2 &&
        snapshot.bottom4Ids.toSet().containsAll(snapshot.jurySavedIds) &&
        snapshot.bottom4Ids
            .toSet()
            .containsAll(snapshot.finalCutContestantIds) &&
        snapshot.jurySavedIds
            .toSet()
            .intersection(snapshot.finalCutContestantIds.toSet())
            .isEmpty;
    if (!valid) throw StateError('Day 3 Icon Test sonucu geçersiz.');
    _day3IconResultSnapshot = snapshot;
    notifyListeners();
  }

  void completeDay3FinalCut(Day3FinalCutResultSnapshot snapshot) {
    if (_day3FinalCutResultSnapshot != null) return;
    final pair = day3FinalCutContestantIds.toSet();
    final valid = pair.length == 2 &&
        pair.contains(snapshot.winnerContestantId) &&
        pair.contains(snapshot.eliminatedContestantId) &&
        snapshot.winnerContestantId != snapshot.eliminatedContestantId &&
        !pair.any(_eliminatedContestantIds.contains) &&
        _day3IconResultSnapshot!.jurySavedIds
            .toSet()
            .intersection(pair)
            .isEmpty;
    if (!valid) throw StateError('Day 3 Final Cut sonucu geçersiz.');
    _day3FinalCutResultSnapshot = snapshot;
    _eliminatedContestantIds.add(snapshot.eliminatedContestantId);
    if (_eliminatedContestantIds.toSet().length != 3 ||
        activeContestantCount != 12) {
      throw StateError('Day 3 eleme sayımı geçersiz.');
    }
    _day3Completed = true;
    notifyListeners();
  }

  void initializeDay4Rooms(Day4RoomAllocation allocation) {
    if (_day4RoomAllocation != null) return;
    final assigned = allocation.roomByContestantId.keys.toSet();
    final valid = _day3Completed &&
        assigned.length == 12 &&
        !assigned.any(_eliminatedContestantIds.contains) &&
        Day4Room.values.every((room) => allocation.members(room).length == 4);
    if (!valid) throw StateError('Day 4 oda dağılımı geçersiz.');
    _day4RoomAllocation = allocation;
    notifyListeners();
  }

  void lockDay4MentorRoom(Day4Room room) {
    if (_day4MentorRoom != null) return;
    if (_day4RoomAllocation == null) throw StateError('Odalar hazır değil.');
    _day4MentorRoom = room;
    notifyListeners();
  }

  void completeDay4(Day4ResultSnapshot snapshot) {
    if (_day4Completed) return;
    final eliminated = snapshot.eliminatedIds.toSet();
    final valid = _day4MentorRoom == snapshot.mentorRoom &&
        eliminated.length == 3 &&
        Day4Room.values.every((r) =>
            snapshot.allocation.members(r).contains(snapshot.winnerByRoom[r]) &&
            snapshot.allocation
                .members(r)
                .contains(snapshot.eliminatedByRoom[r])) &&
        !eliminated.any(_eliminatedContestantIds.contains);
    if (!valid) throw StateError('Day 4 sonucu geçersiz.');
    _day4ResultSnapshot = snapshot;
    _eliminatedContestantIds.addAll(eliminated);
    if (_eliminatedContestantIds.toSet().length != 6 ||
        activeContestantCount != 9) {
      throw StateError('Day 4 eleme sayımı geçersiz.');
    }
    _day4Completed = true;
    notifyListeners();
  }

  void completeDay5(Day5ResultSnapshot snapshot) {
    if (_day5Completed) return;
    final finalists = snapshot.finalistIds.toSet();
    final eliminated = snapshot.eliminatedIds.toSet();
    final valid = _day4Completed &&
        snapshot.results.length == 9 &&
        finalists.length == 7 &&
        eliminated.length == 2 &&
        finalists.intersection(eliminated).isEmpty &&
        {...finalists, ...eliminated}.length == 9 &&
        !eliminated.any(_eliminatedContestantIds.contains);
    if (!valid) throw StateError('Day 5 sonucu geçersiz.');
    _day5ResultSnapshot = snapshot;
    _eliminatedContestantIds.addAll(eliminated);
    if (_eliminatedContestantIds.toSet().length != 8 ||
        activeContestantCount != 7) {
      throw StateError('Day 5 eleme sayımı geçersiz.');
    }
    _day5Completed = true;
    notifyListeners();
  }

  void lockDay6Evaluation(Day6ResultSnapshot snapshot) {
    if (_day6ResultSnapshot != null) return;
    final finalists = day5FinalistIds.toSet();
    final results = snapshot.results.keys.toSet();
    final recommendation = snapshot.recommendedLineupIds.toSet();
    final valid = _day5Completed &&
        finalists.length == 7 &&
        results.length == 7 &&
        results.containsAll(finalists) &&
        recommendation.length == 5 &&
        finalists.containsAll(recommendation);
    if (!valid) throw StateError('Day 6 değerlendirmesi geçersiz.');
    _day6DebutDirection = snapshot.direction;
    _day6ResultSnapshot = snapshot;
    notifyListeners();
  }

  void confirmFinalLineup({
    required Iterable<int> contestantIds,
    required LineupBalance balance,
    required Map<FinalGroupRole, int> suggestedRoles,
  }) {
    if (_day6FinalLineupConfirmed) return;
    final ids = contestantIds.toSet();
    final finalists = day5FinalistIds.toSet();
    final roles = suggestedRoles.values.toSet();
    final valid = _day6ResultSnapshot != null &&
        ids.length == 5 &&
        finalists.containsAll(ids) &&
        !ids.any(_eliminatedContestantIds.contains) &&
        finalists.difference(ids).length == 2 &&
        suggestedRoles.keys.toSet().containsAll(FinalGroupRole.values) &&
        roles.length == 5 &&
        roles.containsAll(ids);
    if (!valid) throw StateError('Final kadro geçersiz.');
    _playerFinalLineupIds = List.unmodifiable(contestantIds);
    _finalistsOutsideDebutLineupIds =
        List.unmodifiable(day5FinalistIds.where((id) => !ids.contains(id)));
    _finalLineupBalance = balance;
    _suggestedFinalRoles = Map.unmodifiable(suggestedRoles);
    _day6FinalLineupConfirmed = true;
    notifyListeners();
  }

  void completeFinalCustomization({
    required Map<FinalMemberPosition, int> positions,
    required int leaderId,
    required Map<int, MemberColor> colors,
    required Object? automaticTags,
  }) {
    if (_seasonCompleted) return;
    final lineup = _playerFinalLineupIds.toSet();
    final normalizedTags = normalizeAutomaticGroupTags(automaticTags);
    final valid = _day6FinalLineupConfirmed &&
        positions.keys.toSet().containsAll(FinalMemberPosition.values) &&
        positions.values.toSet().length == 5 &&
        lineup.containsAll(positions.values) &&
        lineup.contains(leaderId) &&
        colors.keys.toSet().containsAll(lineup) &&
        colors.values.toSet().length == 5 &&
        normalizedTags.keys.toSet().containsAll(lineup);
    if (!valid) throw StateError('Final grup kişiselleştirmesi geçersiz.');
    _finalMemberPositions = Map.unmodifiable(positions);
    _finalLeaderId = leaderId;
    _finalMemberColors = Map.unmodifiable(colors);
    _automaticGroupTags = normalizedTags;
    notifyListeners();
  }

  void nameAndCompleteGroup(String value) {
    if (_seasonCompleted) return;
    final name = value.trim();
    if (name.isEmpty ||
        name.length > 24 ||
        !_day6FinalLineupConfirmed ||
        _finalMemberPositions.length != 5 ||
        _finalLeaderId == null) {
      throw ArgumentError.value(
          value, 'value', 'Grup adı veya final verisi geçersiz.');
    }
    _groupName = name;
    final lineup = _playerFinalLineupIds;
    final mostPopular = lineup.reduce((a, b) =>
        socialStateFor(a).popularity >= socialStateFor(b).popularity ? a : b);
    final balance = _finalLineupBalance!;
    final overall = (balance.vocal +
            balance.dance +
            balance.stage +
            balance.camera +
            balance.harmony) ~/
        5;
    _groupArchive.add(GroupArchiveEntry(
      groupName: name,
      memberIds: List.unmodifiable(lineup),
      positions: Map.unmodifiable(_finalMemberPositions),
      leaderId: _finalLeaderId!,
      overallScore: overall,
      mostPopularMemberId: mostPopular,
      completedAt: DateTime.now(),
    ));
    _seasonCompleted = true;
    notifyListeners();
  }

  void completeFinalReveal() {
    if (!_day6FinalLineupConfirmed) {
      throw StateError('Final kadro onaylanmadı.');
    }
    if (_finalRevealCompleted) return;
    _finalRevealCompleted = true;
    notifyListeners();
  }

  void resetSeason() {
    _seasonSeed = DateTime.now().microsecondsSinceEpoch;
    _resetLivingSeason();
    _playerRadarContestantIds = const [];
    _evaluation1Completed = false;
    _evaluation1Results = const {};
    _producerSaveContestantId = null;
    _jurySaveContestantId = null;
    _lastChanceContestantIds = const [];
    _juryDecision1Completed = false;
    _lastChanceCoachContestantId = null;
    _lastChanceResults = const {};
    _eliminatedContestantIds.clear();
    _lastChance1Completed = false;
    _day2CaptainAId = null;
    _day2CaptainBId = null;
    _day2TeamAIds = const [];
    _day2TeamBIds = const [];
    _day2TeamDraftEvents = const [];
    _day2LastPickedContestantId = null;
    _day2TeamAAverages = null;
    _day2TeamBAverages = null;
    _day2TeamFormationCompleted = false;
    _day2RehearsalSetup = null;
    _day2PlayerInterventionTeamId = null;
    _day2RehearsalOutcome = null;
    _day2RehearsalCompleted = false;
    _day2GroupPerformanceSnapshot = null;
    _day2StarImmunityContestantId = null;
    _day2JuryRiskContestantIds = const [];
    _day2GroupPerformanceCompleted = false;
    _day2JuryResultSnapshot = null;
    _day2JuryTableCompleted = false;
    _day2DuelResultSnapshot = null;
    _day2DuelCompleted = false;
    _day2Completed = false;
    _day3IdentityAllocation = null;
    _day3IdentitySetupSnapshot = null;
    _day3IdentitySetupCompleted = false;
    _day3IconResultSnapshot = null;
    _day3FinalCutResultSnapshot = null;
    _day3Completed = false;
    _day4RoomAllocation = null;
    _day4MentorRoom = null;
    _day4ResultSnapshot = null;
    _day4Completed = false;
    _day5ResultSnapshot = null;
    _day5Completed = false;
    _day6DebutDirection = null;
    _day6ResultSnapshot = null;
    _playerFinalLineupIds = const [];
    _finalistsOutsideDebutLineupIds = const [];
    _finalLineupBalance = null;
    _suggestedFinalRoles = const {};
    _day6FinalLineupConfirmed = false;
    _finalMemberPositions = const {};
    _finalLeaderId = null;
    _finalMemberColors = const {};
    _automaticGroupTags = const {};
    _finalRevealCompleted = false;
    _seasonCompleted = false;
    _groupName = null;
    _performanceAftermath.clear();
    _seenMissionBriefings.clear();
    notifyListeners();
  }
}
