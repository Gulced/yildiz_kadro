import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_localization.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';

/// Presentation-only contestant copy. All gameplay continues to use the
/// stable fields and IDs on [Contestant].
extension ContestantLocalizationX on Contestant {
  String localizedOccupation(BuildContext context) =>
      localized(context).occupation;

  String localizedShortBackground(BuildContext context) =>
      localized(context).shortBackground;

  String localizedFullBackground(BuildContext context) =>
      localized(context).fullBackground;

  String localizedArchetype(BuildContext context) =>
      localized(context).archetype;

  List<String> localizedPersonalityTraits(BuildContext context) =>
      localized(context).personalityTraits;

  String localizedPrimaryRole(BuildContext context) =>
      localized(context).primaryRole;

  List<String> localizedSecondaryRoles(BuildContext context) =>
      localized(context).secondaryRoles;

  String localizedSpecialTraitTitle(BuildContext context) =>
      localized(context).specialTraitTitle;

  String localizedSpecialTraitDescription(BuildContext context) =>
      localized(context).specialTraitDescription;

  String localizedRiskTitle(BuildContext context) =>
      localized(context).riskTitle;

  String localizedRiskDescription(BuildContext context) =>
      localized(context).riskDescription;

  String localizedProducerNote(BuildContext context) =>
      localized(context).producerNote;

  String localizedQuote(BuildContext context) => localized(context).quote;

  ({String label, int value}) localizedStrongestStat(BuildContext context) {
    final raw = strongestStat;
    if (Localizations.localeOf(context).languageCode != 'en') return raw;
    final label = switch (raw.label) {
      'VOKAL' => 'VOCAL',
      'DANS' => 'DANCE',
      'SAHNE' => 'STAGE',
      'POPÜLERLİK' => 'POPULARITY',
      'POTANSİYEL' => 'POTENTIAL',
      _ => throw StateError('Missing stat localization: ${raw.label}'),
    };
    return (label: label, value: raw.value);
  }
}
