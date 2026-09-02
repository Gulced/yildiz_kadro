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
}
