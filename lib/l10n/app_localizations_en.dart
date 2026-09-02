// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Yıldız Kadro';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get continueLabel => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get startSeason => 'Start the Season';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get howToIntro =>
      'You\'re not a contestant—you’re the season\'s producer. Your decisions reshape the stage and every relationship.';

  @override
  String get meetContestants => 'MEET THE CONTESTANTS';

  @override
  String get meetContestantsBody =>
      'Discover all 15 contestants, their talent, goals, and personalities.';

  @override
  String get makeDecisions => 'MAKE THE CALLS';

  @override
  String get makeDecisionsBody =>
      'Build your radar, step into jury decisions, and manage every risk.';

  @override
  String get buildTeams => 'BUILD THE TEAMS';

  @override
  String get buildTeamsBody =>
      'Shape stage chemistry through captain, role, and concept choices.';

  @override
  String get liveResults => 'FACE THE RESULTS';

  @override
  String get liveResultsBody =>
      'Every choice affects performances, relationships, and audience interest.';

  @override
  String get formLineup => 'FORM YOUR LINEUP';

  @override
  String get formLineupBody =>
      'Choose the final five, their positions, leader, and group name.';

  @override
  String get understood => 'GOT IT';

  @override
  String get contestantsAndGroup => '15 contestants.\nOne group of five.';

  @override
  String get landingSupport =>
      'Build the teams, make the calls, and create the final lineup.';

  @override
  String get producerMode => 'PRODUCER MODE';

  @override
  String seasonNumber(String number) {
    return 'SEASON $number';
  }

  @override
  String get producerRight => 'USE PRODUCER SAVE';

  @override
  String get producerRightTitle => 'PRODUCER SAVE';

  @override
  String get selectOnePerson => 'You can save one contestant.';

  @override
  String get applyDecision => 'CONFIRM DECISION';

  @override
  String get decisionApplied => 'DECISION LOCKED';

  @override
  String get crisis => 'CRISIS';

  @override
  String get positiveDevelopment => 'POSITIVE UPDATE';

  @override
  String get socialDevelopment => 'SOCIAL UPDATE';

  @override
  String get performanceDevelopment => 'PERFORMANCE UPDATE';

  @override
  String get relationshipEvent => 'RELATIONSHIP EVENT';

  @override
  String get why => 'WHY NOW?';

  @override
  String get motivation => 'Motivation';

  @override
  String get popularity => 'Popularity';

  @override
  String get followers => 'Followers';

  @override
  String get confidence => 'Confidence';

  @override
  String get professionalism => 'Professionalism';

  @override
  String get energy => 'Energy';

  @override
  String get preparation => 'Preparation';

  @override
  String get relationship => 'Relationship';

  @override
  String get vocalCoach => 'Vocal coach';

  @override
  String get danceCoach => 'Dance coach';

  @override
  String dayLabel(int day) {
    return 'DAY $day';
  }

  @override
  String get castingSeason => 'CASTING • SEASON 01';

  @override
  String get contestants => 'CONTESTANTS';

  @override
  String get meetAllContestants =>
      'Meet all 15 contestants and start imagining your final lineup.';

  @override
  String get seenAllContestants => 'I\'VE MET ALL 15 CONTESTANTS';

  @override
  String get firstImpressionTitle => 'Who made the strongest first impression?';

  @override
  String get firstImpressionBody =>
      'You\'ve met all 15 contestants.\nFor now, choose the five who caught your eye.';

  @override
  String get firstImpressionNote =>
      'This isn\'t an elimination. You can change your mind later.';

  @override
  String radarCount(int count) {
    return '$count / 5 ON YOUR RADAR';
  }

  @override
  String get selectFive => 'CHOOSE 5';

  @override
  String get radarReady => 'MY RADAR IS READY';

  @override
  String get radarLimit => 'You can only keep five contestants on your radar.';

  @override
  String enteredRadar(String name) {
    return '$name is now on your radar ★';
  }

  @override
  String get firstImpressionsComplete => 'First impressions locked in.';

  @override
  String get stageLightsChangeEverything =>
      'But everything can change once the stage lights come on.';

  @override
  String get firstEvaluationStarting =>
      'The first evaluation is about to begin.';

  @override
  String get firstEvaluation => 'FIRST EVALUATION';

  @override
  String get firstImpressionRadar => 'FIRST IMPRESSION RADAR';

  @override
  String get vocal => 'VOCAL';

  @override
  String get dance => 'DANCE';

  @override
  String get stage => 'STAGE';

  @override
  String get goal => 'GOAL';

  @override
  String get strength => 'STRENGTH';

  @override
  String get attention => 'WATCH OUT';

  @override
  String get removeFromRadar => 'REMOVE FROM RADAR';

  @override
  String get addToRadar => 'ADD TO RADAR  ★';
}
