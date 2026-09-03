import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

enum Day4Room { vocal, dance, star }

enum Day4MentorChoice { optionA, optionB }

class Day4RoomAllocation {
  const Day4RoomAllocation({
    required this.roomByContestantId,
    required this.fitByContestantId,
  });
  final Map<int, Day4Room> roomByContestantId;
  final Map<int, double> fitByContestantId;
  List<int> members(Day4Room room) => roomByContestantId.entries
      .where((e) => e.value == room)
      .map((e) => e.key)
      .toList();
}

class Day4ContestantRoomResult {
  const Day4ContestantRoomResult({
    required this.contestantId,
    required this.room,
    required this.categoryA,
    required this.categoryB,
    required this.categoryC,
    required this.rawScore,
    required this.rank,
    required this.playerMentored,
  });
  final int contestantId;
  final Day4Room room;
  final int categoryA;
  final int categoryB;
  final int categoryC;
  final double rawScore;
  final int rank;
  final bool playerMentored;
  int get finalScore => rawScore.round().clamp(0, 100);
}

class Day4ResultSnapshot {
  const Day4ResultSnapshot({
    required this.allocation,
    required this.mentorRoom,
    required this.mentorChoice,
    required this.coachChoiceByRoom,
    required this.results,
    required this.winnerByRoom,
    required this.eliminatedByRoom,
    required this.playerChangedRoomElimination,
  });
  final Day4RoomAllocation allocation;
  final Day4Room mentorRoom;
  final Day4MentorChoice mentorChoice;
  final Map<Day4Room, Day4MentorChoice> coachChoiceByRoom;
  final Map<int, Day4ContestantRoomResult> results;
  final Map<Day4Room, int> winnerByRoom;
  final Map<Day4Room, int> eliminatedByRoom;
  final bool playerChangedRoomElimination;
  List<int> get eliminatedIds =>
      Day4Room.values.map((r) => eliminatedByRoom[r]!).toList();
}

String day4RoomLabel(Day4Room room) => switch (room) {
      Day4Room.vocal => 'VOCAL ROOM',
      Day4Room.dance => 'DANCE ROOM',
      Day4Room.star => 'STAR ROOM',
    };

String day4ChoiceLabel(
  Day4Room room,
  Day4MentorChoice choice, [
  BuildContext? context,
]) {
  final isEn = isAppEnglish(context);
  return switch ((room, choice)) {
    (Day4Room.vocal, Day4MentorChoice.optionA) =>
      isEn ? 'SING WITH PURITY' : 'TEMİZ SÖYLEYİN',
    (Day4Room.vocal, Day4MentorChoice.optionB) =>
      isEn ? 'MAKE YOUR VOICE HEARD' : 'KENDİNİZİ DUYURUN',
    (Day4Room.dance, Day4MentorChoice.optionA) =>
      isEn ? 'STAY IN SYNCHRONICITY' : 'SENKRONDA KALIN',
    (Day4Room.dance, Day4MentorChoice.optionB) =>
      isEn ? 'ADD YOUR OWN FLAIR' : 'KENDİNİZDEN BİR ŞEY EKLEYİN',
    (Day4Room.star, Day4MentorChoice.optionA) =>
      isEn ? 'ONE SIGNATURE MOMENT' : 'TEK BİR İMZA ANI',
    (Day4Room.star, Day4MentorChoice.optionB) =>
      isEn ? 'STAY EFFORTLESSLY NATURAL' : 'DOĞAL KALIN',
  };
}
