import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

const juryRiskPriority = <int>[3, 6, 13, 1, 9];

const juryComments =
    <int, ({String label, String comment, String labelEn, String commentEn})>{
  3: (
    label: 'JÜRİ: POTANSİYEL VAR',
    comment: 'Sahne seni seviyor ama üç alanda da dengeli olman gerekiyor.',
    labelEn: 'JURY: HAS POTENTIAL',
    commentEn:
        'The stage loves you, but you need balance across all three disciplines.',
  ),
  6: (
    label: 'JÜRİ: DAHA FAZLASINI BEKLİYORUZ',
    comment: 'Sıcakkanlılığın güçlü. Şimdi bunu performansa çevirmelisin.',
    labelEn: 'JURY: EXPECTING MORE',
    commentEn:
        'Your warmth is infectious. Now channel it directly into stage execution.',
  ),
  13: (
    label: 'JÜRİ: KONTROLÜ BIRAK',
    comment: 'Teknik olarak hazırsın; şimdi duygunu da sahneye taşımalısın.',
    labelEn: 'JURY: LET GO',
    commentEn: 'Technically ready; now bring your raw emotion onto the stage.',
  ),
  1: (
    label: 'JÜRİ: BEKLENTİ ÇOK YÜKSEK',
    comment:
        'Üç alanda da güçlüsün; kendi baskının performansını yönetmesine izin verme.',
    labelEn: 'JURY: SKY-HIGH EXPECTATIONS',
    commentEn:
        'Strong across the board; do not let self-imposed pressure compromise you.',
  ),
  9: (
    label: 'JÜRİ: FAZLA KONTROLLÜ',
    comment: 'Hatasız olmaya çalışırken kendini göstermeyi unuttun.',
    labelEn: 'JURY: OVERLY CAUTIOUS',
    commentEn: 'In trying to be flawless, you forgot to reveal who you are.',
  ),
};

String localizedJuryLabel(int id, BuildContext context) {
  final entry = juryComments[id];
  if (entry == null) return '';
  return isAppEnglish(context) ? entry.labelEn : entry.label;
}

String localizedJuryComment(int id, BuildContext context) {
  final entry = juryComments[id];
  if (entry == null) return '';
  return isAppEnglish(context) ? entry.commentEn : entry.comment;
}
