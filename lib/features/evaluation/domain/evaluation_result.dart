import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

class EvaluationResult {
  const EvaluationResult({
    required this.contestantId,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.overall,
    required this.comment,
    required this.tag,
    this.commentEn,
    this.tagEn,
  });

  final int contestantId;
  final int vocal;
  final int dance;
  final int stage;
  final int overall;
  final String comment;
  final String tag;
  final String? commentEn;
  final String? tagEn;

  String localizedComment(BuildContext context) =>
      isAppEnglish(context) ? (commentEn ?? comment) : comment;

  String localizedTag(BuildContext context) =>
      isAppEnglish(context) ? (tagEn ?? tag) : tag;
}
