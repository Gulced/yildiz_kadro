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
    label: 'JÜRİ: KONFOR ALANINDAN ÇIK',
    comment: 'Sesin seni taşıyor ama sahnede daha cesur olmalısın.',
  ),
  1: (
    label: 'JÜRİ: HAM AMA İLGİNÇ',
    comment: 'Doğal bir çekimin var. Teknik tarafın aynı seviyede değil.',
  ),
  9: (
    label: 'JÜRİ: FAZLA KONTROLLÜ',
    comment: 'Hatasız olmaya çalışırken kendini göstermeyi unuttun.',
  ),
};
