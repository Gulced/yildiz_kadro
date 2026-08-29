enum FinalMemberPosition {
  mainVocal,
  leadVocal,
  mainDancer,
  leadDancer,
  rapper
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
  silver
}

String finalPositionLabel(FinalMemberPosition value) => switch (value) {
      FinalMemberPosition.mainVocal => 'MAIN VOCAL',
      FinalMemberPosition.leadVocal => 'LEAD VOCAL',
      FinalMemberPosition.mainDancer => 'MAIN DANCER',
      FinalMemberPosition.leadDancer => 'LEAD DANCER',
      FinalMemberPosition.rapper => 'RAPPER / RAP PART',
    };

String memberColorLabel(MemberColor value) => switch (value) {
      MemberColor.pink => 'PEMBE',
      MemberColor.red => 'KIRMIZI',
      MemberColor.purple => 'MOR',
      MemberColor.lavender => 'LAVANTA',
      MemberColor.blue => 'MAVİ',
      MemberColor.turquoise => 'TURKUAZ',
      MemberColor.mint => 'MİNT',
      MemberColor.green => 'YEŞİL',
      MemberColor.yellow => 'SARI',
      MemberColor.orange => 'TURUNCU',
      MemberColor.coral => 'MERCAN',
      MemberColor.burgundy => 'BORDO',
      MemberColor.white => 'BEYAZ',
      MemberColor.black => 'SİYAH',
      MemberColor.silver => 'GÜMÜŞ',
    };
