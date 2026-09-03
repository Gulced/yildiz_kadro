import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

enum FinalMemberPosition {
  mainVocal,
  leadVocal,
  mainDancer,
  leadDancer,
  rapper,
}

enum MemberColor {
  pink,
  red,
  purple,
  lavender,
  blue,
  turquoise,
  mint,
  green,
  yellow,
  orange,
  coral,
  burgundy,
  white,
  black,
  silver,
}

String finalPositionLabel(FinalMemberPosition value) => switch (value) {
      FinalMemberPosition.mainVocal => 'MAIN VOCAL',
      FinalMemberPosition.leadVocal => 'LEAD VOCAL',
      FinalMemberPosition.mainDancer => 'MAIN DANCER',
      FinalMemberPosition.leadDancer => 'LEAD DANCER',
      FinalMemberPosition.rapper => 'RAPPER / RAP PART',
    };

String memberColorLabel(MemberColor value, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (value) {
    MemberColor.pink => isEn ? 'PINK' : 'PEMBE',
    MemberColor.red => isEn ? 'RED' : 'KIRMIZI',
    MemberColor.purple => isEn ? 'PURPLE' : 'MOR',
    MemberColor.lavender => isEn ? 'LAVENDER' : 'LAVANTA',
    MemberColor.blue => isEn ? 'BLUE' : 'MAVİ',
    MemberColor.turquoise => isEn ? 'TURQUOISE' : 'TURKUAZ',
    MemberColor.mint => isEn ? 'MINT' : 'MİNT',
    MemberColor.green => isEn ? 'GREEN' : 'YEŞİL',
    MemberColor.yellow => isEn ? 'YELLOW' : 'SARI',
    MemberColor.orange => isEn ? 'ORANGE' : 'TURUNCU',
    MemberColor.coral => isEn ? 'CORAL' : 'MERCAN',
    MemberColor.burgundy => isEn ? 'BURGUNDY' : 'BORDO',
    MemberColor.white => isEn ? 'WHITE' : 'BEYAZ',
    MemberColor.black => isEn ? 'BLACK' : 'SİYAH',
    MemberColor.silver => isEn ? 'SILVER' : 'GÜMÜŞ',
  };
}
