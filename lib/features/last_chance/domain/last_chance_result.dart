import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

class LastChanceResult {
  const LastChanceResult({
    required this.contestantId,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.baseOverall,
    required this.tag,
    required this.comment,
    this.tagEn,
    this.commentEn,
  });

  final int contestantId;
  final int vocal;
  final int dance;
  final int stage;
  final int baseOverall;
  final String tag;
  final String comment;
  final String? tagEn;
  final String? commentEn;

  String localizedTag(BuildContext context) =>
      isAppEnglish(context) ? (tagEn ?? tag) : tag;

  String localizedComment(BuildContext context) =>
      isAppEnglish(context) ? (commentEn ?? comment) : comment;

  int finalScore({required bool coached}) =>
      (baseOverall + (coached ? 4 : 0)).clamp(0, 100);
}
