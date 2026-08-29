const juryRiskPriority = <int>[3, 6, 13, 1, 9];

const juryComments = <int, ({String label, String comment})>{
  3: (
    label: 'JÜRİ: POTANSİYEL VAR',
    comment: 'Sahne seni seviyor ama üç alanda da dengeli olman gerekiyor.',
  ),
  6: (
    label: 'JÜRİ: DAHA FAZLASINI BEKLİYORUZ',
    comment: 'Sıcakkanlılığın güçlü. Şimdi bunu performansa çevirmelisin.',
  ),
  13: (
    label: 'JÜRİ: KONTROLÜ BIRAK',
    comment: 'Teknik olarak hazırsın; şimdi duygunu da sahneye taşımalısın.',
  ),
  1: (
    label: 'JÜRİ: BEKLENTİ ÇOK YÜKSEK',
    comment:
        'Üç alanda da güçlüsün; kendi baskının performansını yönetmesine izin verme.',
  ),
  9: (
    label: 'JÜRİ: FAZLA KONTROLLÜ',
    comment: 'Hatasız olmaya çalışırken kendini göstermeyi unuttun.',
  ),
};
