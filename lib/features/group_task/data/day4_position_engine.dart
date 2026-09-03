import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_icon_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day4RoomAllocation allocateDay4Rooms({
  required List<int> activeIds,
  required Map<int, EvaluationResult> first,
  required Day2GroupPerformanceSnapshot day2,
  required Day3IconResultSnapshot day3,
}) {
  if (activeIds.length != 12 || activeIds.toSet().length != 12) {
    throw ArgumentError('12 aktif yarışmacı gerekli.');
  }
  double fit(int id, Day4Room room) {
    final f = first[id]!,
        d2 = day2.individualResults[id]!,
        d3 = day3.results[id]!,
        p = groupTaskProfiles[id]!;
    if (room == Day4Room.vocal) {
      return f.vocal * .55 +
          d2.vocal * .20 +
          d3.performance * .10 +
          d3.identity * .05 +
          d3.camera * .10 +
          (p.primaryRole == GroupRole.vocal
              ? 6
              : p.secondaryRole == GroupRole.vocal
                  ? 3
                  : 0) +
          switch (p.workStyle) {
            WorkStyle.calm || WorkStyle.experienced => 2,
            WorkStyle.sensitive ||
            WorkStyle.controlled ||
            WorkStyle.protective =>
              1,
            _ => 0,
          };
    }
    if (room == Day4Room.dance) {
      return f.dance * .55 +
          d2.dance * .20 +
          d3.performance * .15 +
          d3.camera * .10 +
          (p.primaryRole == GroupRole.dance
              ? 6
              : p.secondaryRole == GroupRole.dance
                  ? 3
                  : 0) +
          switch (p.workStyle) {
            WorkStyle.experienced || WorkStyle.competitive => 2,
            WorkStyle.controlled ||
            WorkStyle.bold ||
            WorkStyle.spontaneous =>
              1,
            _ => 0,
          };
    }
    return f.stage * .35 +
        d2.stage * .20 +
        d3.camera * .25 +
        d3.identity * .20 +
        (p.primaryRole == GroupRole.stage
            ? 5
            : p.secondaryRole == GroupRole.stage
                ? 2
                : 0) +
        switch (p.workStyle) {
          WorkStyle.cameraSavvy => 4,
          WorkStyle.bold || WorkStyle.playful || WorkStyle.instinctive => 2,
          WorkStyle.spontaneous || WorkStyle.social => 1,
          _ => 0,
        };
  }

  List<int>? bestV, bestD;
  var best = -double.infinity;
  final ids = activeIds.toList()..sort();
  for (final v in _combinations(ids, 4)) {
    final rest = ids.where((id) => !v.contains(id)).toList();
    for (final d in _combinations(rest, 4)) {
      final s = rest.where((id) => !d.contains(id));
      final total = v.fold<double>(0, (x, id) => x + fit(id, Day4Room.vocal)) +
          d.fold<double>(0, (x, id) => x + fit(id, Day4Room.dance)) +
          s.fold<double>(0, (x, id) => x + fit(id, Day4Room.star));
      if (total > best) {
        best = total;
        bestV = v;
        bestD = d;
      }
    }
  }
  final rooms = <int, Day4Room>{};
  final fits = <int, double>{};
  for (final id in ids) {
    final room = bestV!.contains(id)
        ? Day4Room.vocal
        : bestD!.contains(id)
            ? Day4Room.dance
            : Day4Room.star;
    rooms[id] = room;
    fits[id] = fit(id, room);
  }
  return Day4RoomAllocation(
    roomByContestantId: Map.unmodifiable(rooms),
    fitByContestantId: Map.unmodifiable(fits),
  );
}

Iterable<List<int>> _combinations(List<int> values, int count) sync* {
  if (count == 0) {
    yield const [];
    return;
  }
  for (var i = 0; i <= values.length - count; i++) {
    for (final tail in _combinations(values.sublist(i + 1), count - 1)) {
      yield [values[i], ...tail];
    }
  }
}

Day4ResultSnapshot calculateDay4Results({
  required Day4RoomAllocation allocation,
  required Day4Room mentorRoom,
  required Day4MentorChoice mentorChoice,
  required Map<int, EvaluationResult> first,
  required Day2GroupPerformanceSnapshot day2,
  required Day3IconResultSnapshot day3,
}) {
  final coaches = <Day4Room, Day4MentorChoice>{};
  for (final room in Day4Room.values) {
    if (room == mentorRoom) {
      coaches[room] = mentorChoice;
      continue;
    }
    final members = allocation.members(room);
    final a = members.fold<int>(
      0,
      (x, id) =>
          x +
          _choiceMod(
            room,
            Day4MentorChoice.optionA,
            groupTaskProfiles[id]!,
            false,
          ),
    );
    final b = members.fold<int>(
      0,
      (x, id) =>
          x +
          _choiceMod(
            room,
            Day4MentorChoice.optionB,
            groupTaskProfiles[id]!,
            false,
          ),
    );
    coaches[room] =
        a >= b ? Day4MentorChoice.optionA : Day4MentorChoice.optionB;
  }
  Map<int, (int, int, int, double)> calculate({required bool removePlayer}) {
    final out = <int, (int, int, int, double)>{};
    for (final id in allocation.roomByContestantId.keys) {
      final room = allocation.roomByContestantId[id]!,
          f = first[id]!,
          d2 = day2.individualResults[id]!,
          d3 = day3.results[id]!,
          p = groupTaskProfiles[id]!;
      int a, b, c;
      if (room == Day4Room.vocal) {
        a = (f.vocal * .60 + d2.vocal * .25 + d3.performance * .15).round();
        b = (a * .40 +
                d3.performance * .20 +
                75 * .40 +
                _style(p.workStyle, room, 1))
            .round();
        c = (d3.identity * .30 + d3.camera * .20 + a * .30 + f.overall * .20)
            .round();
      } else if (room == Day4Room.dance) {
        a = (f.dance * .60 +
                d2.dance * .25 +
                d3.performance * .15 +
                _style(p.workStyle, room, 0))
            .round();
        b = (f.dance * .45 + 75 * .30 + d2.dance * .25).round();
        c = (d3.camera * .30 +
                f.stage * .30 +
                d3.identity * .20 +
                f.dance * .20 +
                _style(p.workStyle, room, 2))
            .round();
      } else {
        a = (d3.camera * .50 +
                f.stage * .25 +
                d2.stage * .15 +
                d3.identity * .10)
            .round();
        b = (d3.identity * .35 +
                d3.camera * .25 +
                f.stage * .25 +
                75 * .15 +
                _style(p.workStyle, room, 1))
            .round();
        c = (d3.iconScore * .35 +
                d3.camera * .25 +
                d3.identity * .25 +
                75 * .15 +
                _style(p.workStyle, room, 2))
            .round();
      }
      final player = room == mentorRoom && !removePlayer;
      final mod = _choiceMod(room, coaches[room]!, p, player);
      final raw = (room == Day4Room.vocal
              ? a * .45 + b * .30 + c * .25
              : room == Day4Room.dance
                  ? a * .45 + b * .25 + c * .30
                  : a * .40 + b * .30 + c * .30) +
          mod;
      out[id] = (
        a.clamp(0, 100),
        b.clamp(0, 100),
        c.clamp(0, 100),
        raw.clamp(0, 100),
      );
    }
    return out;
  }

  final scored = calculate(removePlayer: false),
      baseline = calculate(removePlayer: true);
  final results = <int, Day4ContestantRoomResult>{},
      winners = <Day4Room, int>{},
      eliminated = <Day4Room, int>{};
  int loser(Map<int, (int, int, int, double)> map, Day4Room room) {
    final ids = allocation.members(room)
      ..sort((x, y) {
        var c = map[y]!.$4.compareTo(map[x]!.$4);
        if (c != 0) return c;
        c = map[y]!.$1.compareTo(map[x]!.$1);
        return c != 0 ? c : x.compareTo(y);
      });
    return ids.last;
  }

  for (final room in Day4Room.values) {
    final ids = allocation.members(room)
      ..sort((x, y) {
        var c = scored[y]!.$4.compareTo(scored[x]!.$4);
        if (c != 0) return c;
        c = scored[y]!.$1.compareTo(scored[x]!.$1);
        return c != 0 ? c : x.compareTo(y);
      });
    winners[room] = ids.first;
    eliminated[room] = ids.last;
    for (var i = 0; i < ids.length; i++) {
      final v = scored[ids[i]]!;
      results[ids[i]] = Day4ContestantRoomResult(
        contestantId: ids[i],
        room: room,
        categoryA: v.$1,
        categoryB: v.$2,
        categoryC: v.$3,
        rawScore: v.$4,
        rank: i + 1,
        playerMentored: room == mentorRoom,
      );
    }
  }
  return Day4ResultSnapshot(
    allocation: allocation,
    mentorRoom: mentorRoom,
    mentorChoice: mentorChoice,
    coachChoiceByRoom: Map.unmodifiable(coaches),
    results: Map.unmodifiable(results),
    winnerByRoom: Map.unmodifiable(winners),
    eliminatedByRoom: Map.unmodifiable(eliminated),
    playerChangedRoomElimination:
        loser(scored, mentorRoom) != loser(baseline, mentorRoom),
  );
}

int _choiceMod(
  Day4Room room,
  Day4MentorChoice choice,
  GroupTaskProfile p,
  bool player,
) {
  var v = 0;
  if (choice == Day4MentorChoice.optionA) {
    v = switch (p.workStyle) {
      WorkStyle.controlled || WorkStyle.calm => 3,
      WorkStyle.experienced || WorkStyle.observant => 2,
      WorkStyle.chaotic => -2,
      WorkStyle.spontaneous => -1,
      _ => 0,
    };
    if (room == Day4Room.star &&
        (p.workStyle == WorkStyle.cameraSavvy ||
            p.workStyle == WorkStyle.bold)) {
      v = 3;
    }
  } else {
    v = switch (p.workStyle) {
      WorkStyle.bold || WorkStyle.spontaneous => 3,
      WorkStyle.playful ||
      WorkStyle.competitive ||
      WorkStyle.cameraSavvy ||
      WorkStyle.instinctive =>
        2,
      WorkStyle.sensitive || WorkStyle.social => 1,
      _ => 0,
    };
  }
  return player ? v.clamp(-3, 3) : (v * .67).round().clamp(-2, 2);
}

int _style(WorkStyle s, Day4Room r, int category) => switch (s) {
      WorkStyle.experienced => 3,
      WorkStyle.controlled || WorkStyle.competitive => 2,
      WorkStyle.cameraSavvy => r == Day4Room.star ? 5 : 0,
      WorkStyle.bold ||
      WorkStyle.playful ||
      WorkStyle.instinctive ||
      WorkStyle.spontaneous =>
        category == 2 ? 3 : 1,
      WorkStyle.chaotic => category == 0 ? -2 : 2,
      _ => 1,
    };
