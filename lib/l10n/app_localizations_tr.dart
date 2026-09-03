// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Yıldız Kadro';

  @override
  String get language => 'Dil';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get continueLabel => 'Devam Et';

  @override
  String get back => 'Geri';

  @override
  String get confirm => 'Onayla';

  @override
  String get cancel => 'İptal';

  @override
  String get startSeason => 'Sezona Başla';

  @override
  String get howToPlay => 'Nasıl Oynanır?';

  @override
  String get howToIntro =>
      'Sen bir yarışmacı değil, sezonun yapımcısısın. Kararların sahneyi ve ilişkileri değiştirir.';

  @override
  String get meetContestants => 'YARIŞMACILARI TANI';

  @override
  String get meetContestantsBody =>
      '15 adayın yeteneklerini, hedeflerini ve karakterlerini keşfet.';

  @override
  String get makeDecisions => 'KARAR VER';

  @override
  String get makeDecisionsBody =>
      'Radarını kur, jüri kararlarına müdahale et ve riskleri yönet.';

  @override
  String get buildTeams => 'TAKIMLARI KUR';

  @override
  String get buildTeamsBody =>
      'Kaptan, rol ve konsept seçimleriyle sahne uyumunu şekillendir.';

  @override
  String get liveResults => 'SONUÇLARI YAŞA';

  @override
  String get liveResultsBody =>
      'Her tercih performansları, ilişkileri ve izleyici ilgisini etkiler.';

  @override
  String get formLineup => 'KADRONU ÇIKAR';

  @override
  String get formLineupBody =>
      'Finalde beş üyeyi, pozisyonları, lideri ve grup adını sen belirle.';

  @override
  String get understood => 'ANLADIM';

  @override
  String get contestantsAndGroup => '15 yarışmacı.\n5 kişilik\nbir grup.';

  @override
  String get landingSupport =>
      'Takımları kur, kararlarını ver ve final kadrosunu sen oluştur.';

  @override
  String get producerMode => 'YAPIMCI MODU';

  @override
  String seasonNumber(String number) {
    return 'SEZON $number';
  }

  @override
  String get producerRight => 'YAPIMCI HAKKINI KULLAN';

  @override
  String get producerRightTitle => 'YAPIMCI HAKKI';

  @override
  String get selectOnePerson => 'Bir kişiyi koruyabilirsin.';

  @override
  String get applyDecision => 'KARARI UYGULA';

  @override
  String get decisionApplied => 'KARAR UYGULANDI';

  @override
  String get crisis => 'KRİZ';

  @override
  String get positiveDevelopment => 'OLUMLU GELİŞME';

  @override
  String get socialDevelopment => 'SOSYAL GELİŞME';

  @override
  String get performanceDevelopment => 'PERFORMANS GELİŞMESİ';

  @override
  String get relationshipEvent => 'İLİŞKİ OLAYI';

  @override
  String get why => 'NEDEN?';

  @override
  String get motivation => 'Motivasyon';

  @override
  String get popularity => 'Popülerlik';

  @override
  String get followers => 'Takipçi';

  @override
  String get confidence => 'Özgüven';

  @override
  String get professionalism => 'Profesyonellik';

  @override
  String get energy => 'Enerji';

  @override
  String get preparation => 'Hazırlık';

  @override
  String get relationship => 'İlişki';

  @override
  String get vocalCoach => 'Vokal hocası';

  @override
  String get danceCoach => 'Dans hocası';

  @override
  String dayLabel(int day) {
    return '$day. GÜN';
  }

  @override
  String get castingSeason => 'CASTING • SEZON 01';

  @override
  String get contestants => 'YARIŞMACILAR';

  @override
  String get meetAllContestants =>
      '15 yarışmacıyı tanı. Final kadronu şimdiden düşünmeye başla.';

  @override
  String get seenAllContestants => '15 YARIŞMACIYI GÖRDÜM';

  @override
  String get firstImpressionTitle => 'İlk izlenimin kimden yana?';

  @override
  String get firstImpressionBody =>
      '15 yarışmacıyla tanıştın.\nŞimdilik sadece dikkatini çeken 5 kişiyi seç.';

  @override
  String get firstImpressionNote =>
      'Bu bir eleme değil. Fikrini daha sonra değiştirebilirsin.';

  @override
  String radarCount(int count) {
    return '$count / 5 RADARDA';
  }

  @override
  String get selectFive => '5 KİŞİ SEÇ';

  @override
  String get radarReady => 'RADARIM HAZIR';

  @override
  String get radarLimit => 'Radarında sadece 5 kişi olabilir.';

  @override
  String enteredRadar(String name) {
    return '$name radarına girdi ★';
  }

  @override
  String get firstImpressionsComplete => 'İlk izlenimler tamam.';

  @override
  String get stageLightsChangeEverything =>
      'Ama sahne ışıkları yandığında her şey değişebilir.';

  @override
  String get firstEvaluationStarting => 'İlk değerlendirme başlıyor.';

  @override
  String get firstEvaluation => 'İLK DEĞERLENDİRME';

  @override
  String get firstImpressionRadar => 'İLK İZLENİM RADARI';

  @override
  String get vocal => 'VOKAL';

  @override
  String get dance => 'DANS';

  @override
  String get stage => 'SAHNE';

  @override
  String get goal => 'HEDEF';

  @override
  String get strength => 'GÜÇLÜ TARAF';

  @override
  String get attention => 'DİKKAT';

  @override
  String get removeFromRadar => 'RADARDAN ÇIKAR';

  @override
  String get addToRadar => 'RADARA AL  ★';

  @override
  String get producerDesk => 'YAPIMCI MASASI';

  @override
  String get tabOverview => 'GÜNDEM';

  @override
  String get tabTeams => 'TAKIMLAR';

  @override
  String get tabBackstage => 'KULİS';

  @override
  String get backstagePreparing => 'KULİS HAZIRLANIYOR';

  @override
  String get backstagePreparingDesc =>
      'Günün gelişmeleri kısa süre içinde yapımcı masasına düşecek.';

  @override
  String get backstageInterview => 'KULİS RÖPORTAJI';

  @override
  String get applyThisDecision => 'BU KARARI UYGULA';

  @override
  String get history => 'GEÇMİŞ';

  @override
  String get captain => 'KAPTAN';

  @override
  String get roleCenter => 'CENTER';

  @override
  String get roleMainVocal => 'ANA VOKAL';

  @override
  String get roleDanceLead => 'DANS LİDERİ';

  @override
  String get noEventScheduledToday => 'Bugün için planlanan kulis olayı yok.';

  @override
  String get activeContestants => 'Aktif Yarışmacı';

  @override
  String get topMorale => 'En Yüksek Moral';

  @override
  String get topPopularity => 'En Popüler';

  @override
  String get topBuzz => 'En Çok Konuşulan';

  @override
  String get criticalEnergy => 'Kritik Enerji';

  @override
  String get story => 'HİKÂYESİ';

  @override
  String get personality => 'KİŞİLİK';

  @override
  String get specialTrait => 'ÖZEL ÖZELLİK';

  @override
  String get risk => 'RİSK';

  @override
  String get talentReport => 'YETENEK RAPORU';

  @override
  String get role => 'ROL';

  @override
  String get producerNoteLabel => 'YAPIMCI NOTU';

  @override
  String get potential => 'POTANSİYEL';

  @override
  String ageWithCity(int age, String city) {
    return '$age • $city';
  }

  @override
  String get stageTest => '1. GÜN • SAHNE TESTİ';

  @override
  String get evalCompleteTitle => 'İLK DEĞERLENDİRME\nTAMAMLANDI';

  @override
  String get evalCompleteDesc =>
      'İlk sahne bazı beklentileri doğruladı.\nBazılarını ise tamamen değiştirdi.';

  @override
  String get topFiveTonight => 'GECENİN İLK 5’İ';

  @override
  String get outsideRadarSurprise => 'RADAR DIŞI SÜRPRİZ';

  @override
  String get radarTop => 'RADARIN EN YÜKSEĞİ';

  @override
  String get radarRisk => 'RADARIN RİSKLİSİ';

  @override
  String get radarPerformance => 'RADAR PERFORMANSI';

  @override
  String radarAverageScore(String score) {
    return 'Radar ortalaması: $score';
  }

  @override
  String get goToJuryRoom => 'JÜRİ ODASINA GEÇ';

  @override
  String get seeResults => 'SONUÇLARI GÖR';

  @override
  String get nextContestant => 'SONRAKİ YARIŞMACI';

  @override
  String get radarPaidOff => '★ Radar seçimin karşılığını verdi.';

  @override
  String get radarDebatable => '★ İlk izlenimin şimdilik tartışmalı.';

  @override
  String get notOnRadarThinkAgain =>
      'Onu radarına almamıştın.\nBelki tekrar düşünmelisin.';

  @override
  String revealProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get juryDecisionTitle => 'JÜRİ KARARI';

  @override
  String get scoresDontSayAll => 'Puanlar her şeyi söylemez.';

  @override
  String get juryIntroDesc =>
      'İlk değerlendirme tamamlandı.\nŞimdi jüri masası konuşuyor.';

  @override
  String get lowestFiveRisk =>
      'En düşük 5 puanı alan yarışmacı risk bölgesinde.';

  @override
  String get oneDecisionIsYours => 'Ama bu gece bir karar sana ait.';

  @override
  String get viewRiskZone => 'RİSK BÖLGESİNİ GÖR';

  @override
  String get safe => 'GÜVENDE';

  @override
  String get faceTheJury => 'JÜRİNİN KARŞISINA ÇIK';

  @override
  String get riskZone => 'RİSK BÖLGESİ';

  @override
  String get riskZoneDesc => 'Bu gece elenme riski taşıyan 5 yarışmacı:';

  @override
  String get protectOnePerson => 'BİR KİŞİYİ KORU';

  @override
  String get confirmProtection => 'KORUMAYI ONAYLA';

  @override
  String protectingContestant(String name) {
    return '$name’Yİ KORUYORSUN';
  }

  @override
  String protectionWarning(String name) {
    return '$name bu gece doğrudan güvende olacak.\nBu kararı daha sonra değiştiremezsin.';
  }

  @override
  String get yesProtect => 'EVET, KORU';

  @override
  String get goBack => 'GERİ DÖN';

  @override
  String get producerRightUsed => 'YAPIMCI HAKKI KULLANILDI';

  @override
  String producerProtectedMsg(String name) {
    return 'Yapımcı olarak $name’yi korudun.\nDoğrudan bir sonraki güne geçti.';
  }

  @override
  String get jurySavedTop => 'Jüri en yüksek puana sahip adayı korudu.';

  @override
  String get juryProtected => 'JÜRİ KORUDU';

  @override
  String get goToLastChance => 'SON ŞANS SAHNESİNE GEÇ';

  @override
  String get juryDecisionSummaryTitle => 'JÜRİ DEĞERLENDİRMESİ TAMAMLANDI';

  @override
  String get juryDecisionSummaryDesc =>
      'Yapımcı hakkı ve jüri tercihi sonrası 3 aday son şans sahnesinde.';

  @override
  String get lastChanceTitle => 'SON ŞANS SAHNESİ';

  @override
  String get threeContestantsOneFarewell => '3 yarışmacı.\n1 veda.';

  @override
  String get lastChanceIntroDesc =>
      'Puanlar sıfırlanmadı ama her şey bu performansa bağlı.';

  @override
  String get enterStage => 'SAHNEYE GEÇ';

  @override
  String givingCoachingNote(String name) {
    return '$name’YE SAHNE NOTU VERİYORSUN';
  }

  @override
  String get coachingSingleWarning =>
      'Bu bölümde yalnızca bir yarışmacıya müdahale edebilirsin.';

  @override
  String get yesSelect => 'EVET, SEÇ';

  @override
  String get coachingPrompt =>
      'Bir yarışmacıya kritik sahne notu ver (+3 puan):';

  @override
  String get noIntervention => 'MÜDAHALE ETMEDEN İZLE';

  @override
  String get confirmChoice => 'TERCİHİ ONAYLA';

  @override
  String get performanceReveal => 'PERFORMANS DEĞERLENDİRMESİ';

  @override
  String get scoresCompared => 'PUANLAR KARŞILAŞTIRILIYOR';

  @override
  String get firstSafeContestant => 'GÜVENDE OLAN İLK İSİM';

  @override
  String get finalTwoTitle => 'SON İKİ YARIŞMACI';

  @override
  String get farewellTitle => 'VEDA ANI';

  @override
  String farewellDesc(String name) {
    return '$name yarışmaya veda etti.';
  }

  @override
  String get coachedBadge => 'KOÇLUK DESTEĞİ ALDI (+3)';

  @override
  String get continueToRoster => 'KADRO GÜNCELLEMESİNE GEÇ';

  @override
  String get day1Complete => '1. GÜN TAMAMLANDI';

  @override
  String activeRemainingCount(int count) {
    return '$count KİŞİ KALDI';
  }

  @override
  String get firstDayLessonsDesc =>
      'İlk günün ardından kadro şekillenmeye başladı.\nŞimdi sıra takım görevinde.';

  @override
  String get eliminatedMember => 'ELENEN YARIŞMACI';

  @override
  String get activeRoster => 'DEVAM EDEN YARIŞMACILAR';

  @override
  String get advanceToDay2 => '2. GÜNE GEÇ';

  @override
  String get day2Title => '2. GÜN • GRUP GÖREVİ';

  @override
  String get groupTaskBriefing => 'Grup Görevi: Şarkı ve Uyum';

  @override
  String get teamFormationTitle => 'TAKIM KURULUMU';

  @override
  String get teamA => 'A TAKIMI';

  @override
  String get teamB => 'B TAKIMI';

  @override
  String get autoFormTeams => 'OTOMATİK TAKIMLARI ONAYLA';

  @override
  String get manualBuilder => 'MANUEL KADRO KUR';

  @override
  String get rehearsalTitle => 'PROVA ODASI';

  @override
  String get rehearsalCrisesTitle => 'PROVA KRİZİ';

  @override
  String get resolveCrisis => 'KRİZİ ÇÖZ';

  @override
  String get groupStageTitle => 'GRUP SAHNESİ';

  @override
  String get groupResultsTitle => 'GRUP SONUÇLARI';

  @override
  String get winningTeamImmune => 'KAZANAN TAKIM DOKUNULMAZ';

  @override
  String get juryTableTitle => 'JÜRİ MASASI';

  @override
  String get duelTitle => 'İKİLİ DÜELLO';

  @override
  String get duelWinner => 'DÜELLO KAZANANI';

  @override
  String get duelElimination => 'DÜELLO ELEMESİ';

  @override
  String get advanceToDay3 => '3. GÜNE GEÇ';

  @override
  String get day3Title => '3. GÜN • İKON ŞARKILAR';

  @override
  String get iconStageBriefing => 'İkon Sahnesi';

  @override
  String get iconPerformanceResults => 'İkon Performans Sonuçları';

  @override
  String get finalCutTitle => 'YARI FİNAL ELEMESİ';

  @override
  String get advanceToDay4 => '4. GÜNE GEÇ';

  @override
  String get day4Title => '4. GÜN • POZİSYON SAVAŞI';

  @override
  String get positionBattleBriefing => 'Pozisyon Savaşı';

  @override
  String get roomVocal => 'VOKAL ODASI';

  @override
  String get roomDance => 'DANS ODASI';

  @override
  String get roomStage => 'SAHNE ODASI';

  @override
  String get positionBattleResults => 'Pozisyon Savaşı Sonuçları';

  @override
  String get advanceToDay5 => '5. GÜNE GEÇ';

  @override
  String get day5Title => '5. GÜN • CANLI YAYIN';

  @override
  String get liveShowBriefing => 'Canlı Yayın Gösterisi';

  @override
  String get broadcastDirection => 'YAYIN STRATEJİSİ';

  @override
  String get liveShowResults => 'Canlı Yayın Sonuçları';

  @override
  String get advanceToGrandFinal => 'BÜYÜK FİNALE GEÇ';

  @override
  String get grandFinalTitle => 'BÜYÜK FİNAL';

  @override
  String get selectFinalFive => 'FİNAL 5’LİYİ SEÇ';

  @override
  String get conceptSelection => 'ÇIKIŞ KONSEPTİ';

  @override
  String get groupNaming => 'GRUP ADINI KOY';

  @override
  String get enterGroupName => 'Grup Adı Girin';

  @override
  String get confirmDebut => 'ÇIKIŞI ONAYLA';

  @override
  String get debutPoster => 'ÇIKIŞ POSTERİ';

  @override
  String get seasonComplete => 'SEZON TAMAMLANDI';

  @override
  String get newSeason => 'YENİ SEZON';

  @override
  String get startNewSeason => 'YENİ SEZONA BAŞLA';

  @override
  String scoreLabel(int score) {
    return 'Puan: $score';
  }

  @override
  String rankLabel(int rank) {
    return '$rank.';
  }
}
