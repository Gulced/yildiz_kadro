import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yıldız Kadro'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @continueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @startSeason.
  ///
  /// In tr, this message translates to:
  /// **'Sezona Başla'**
  String get startSeason;

  /// No description provided for @howToPlay.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl Oynanır?'**
  String get howToPlay;

  /// No description provided for @howToIntro.
  ///
  /// In tr, this message translates to:
  /// **'Sen bir yarışmacı değil, sezonun yapımcısısın. Kararların sahneyi ve ilişkileri değiştirir.'**
  String get howToIntro;

  /// No description provided for @meetContestants.
  ///
  /// In tr, this message translates to:
  /// **'YARIŞMACILARI TANI'**
  String get meetContestants;

  /// No description provided for @meetContestantsBody.
  ///
  /// In tr, this message translates to:
  /// **'15 adayın yeteneklerini, hedeflerini ve karakterlerini keşfet.'**
  String get meetContestantsBody;

  /// No description provided for @makeDecisions.
  ///
  /// In tr, this message translates to:
  /// **'KARAR VER'**
  String get makeDecisions;

  /// No description provided for @makeDecisionsBody.
  ///
  /// In tr, this message translates to:
  /// **'Radarını kur, jüri kararlarına müdahale et ve riskleri yönet.'**
  String get makeDecisionsBody;

  /// No description provided for @buildTeams.
  ///
  /// In tr, this message translates to:
  /// **'TAKIMLARI KUR'**
  String get buildTeams;

  /// No description provided for @buildTeamsBody.
  ///
  /// In tr, this message translates to:
  /// **'Kaptan, rol ve konsept seçimleriyle sahne uyumunu şekillendir.'**
  String get buildTeamsBody;

  /// No description provided for @liveResults.
  ///
  /// In tr, this message translates to:
  /// **'SONUÇLARI YAŞA'**
  String get liveResults;

  /// No description provided for @liveResultsBody.
  ///
  /// In tr, this message translates to:
  /// **'Her tercih performansları, ilişkileri ve izleyici ilgisini etkiler.'**
  String get liveResultsBody;

  /// No description provided for @formLineup.
  ///
  /// In tr, this message translates to:
  /// **'KADRONU ÇIKAR'**
  String get formLineup;

  /// No description provided for @formLineupBody.
  ///
  /// In tr, this message translates to:
  /// **'Finalde beş üyeyi, pozisyonları, lideri ve grup adını sen belirle.'**
  String get formLineupBody;

  /// No description provided for @understood.
  ///
  /// In tr, this message translates to:
  /// **'ANLADIM'**
  String get understood;

  /// No description provided for @contestantsAndGroup.
  ///
  /// In tr, this message translates to:
  /// **'15 yarışmacı.\n5 kişilik\nbir grup.'**
  String get contestantsAndGroup;

  /// No description provided for @landingSupport.
  ///
  /// In tr, this message translates to:
  /// **'Takımları kur, kararlarını ver ve final kadrosunu sen oluştur.'**
  String get landingSupport;

  /// No description provided for @producerMode.
  ///
  /// In tr, this message translates to:
  /// **'YAPIMCI MODU'**
  String get producerMode;

  /// No description provided for @seasonNumber.
  ///
  /// In tr, this message translates to:
  /// **'SEZON {number}'**
  String seasonNumber(String number);

  /// No description provided for @producerRight.
  ///
  /// In tr, this message translates to:
  /// **'YAPIMCI HAKKINI KULLAN'**
  String get producerRight;

  /// No description provided for @producerRightTitle.
  ///
  /// In tr, this message translates to:
  /// **'YAPIMCI HAKKI'**
  String get producerRightTitle;

  /// No description provided for @selectOnePerson.
  ///
  /// In tr, this message translates to:
  /// **'Bir kişiyi koruyabilirsin.'**
  String get selectOnePerson;

  /// No description provided for @applyDecision.
  ///
  /// In tr, this message translates to:
  /// **'KARARI UYGULA'**
  String get applyDecision;

  /// No description provided for @decisionApplied.
  ///
  /// In tr, this message translates to:
  /// **'KARAR UYGULANDI'**
  String get decisionApplied;

  /// No description provided for @crisis.
  ///
  /// In tr, this message translates to:
  /// **'KRİZ'**
  String get crisis;

  /// No description provided for @positiveDevelopment.
  ///
  /// In tr, this message translates to:
  /// **'OLUMLU GELİŞME'**
  String get positiveDevelopment;

  /// No description provided for @socialDevelopment.
  ///
  /// In tr, this message translates to:
  /// **'SOSYAL GELİŞME'**
  String get socialDevelopment;

  /// No description provided for @performanceDevelopment.
  ///
  /// In tr, this message translates to:
  /// **'PERFORMANS GELİŞMESİ'**
  String get performanceDevelopment;

  /// No description provided for @relationshipEvent.
  ///
  /// In tr, this message translates to:
  /// **'İLİŞKİ OLAYI'**
  String get relationshipEvent;

  /// No description provided for @why.
  ///
  /// In tr, this message translates to:
  /// **'NEDEN?'**
  String get why;

  /// No description provided for @motivation.
  ///
  /// In tr, this message translates to:
  /// **'Motivasyon'**
  String get motivation;

  /// No description provided for @popularity.
  ///
  /// In tr, this message translates to:
  /// **'Popülerlik'**
  String get popularity;

  /// No description provided for @followers.
  ///
  /// In tr, this message translates to:
  /// **'Takipçi'**
  String get followers;

  /// No description provided for @confidence.
  ///
  /// In tr, this message translates to:
  /// **'Özgüven'**
  String get confidence;

  /// No description provided for @professionalism.
  ///
  /// In tr, this message translates to:
  /// **'Profesyonellik'**
  String get professionalism;

  /// No description provided for @energy.
  ///
  /// In tr, this message translates to:
  /// **'Enerji'**
  String get energy;

  /// No description provided for @preparation.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık'**
  String get preparation;

  /// No description provided for @relationship.
  ///
  /// In tr, this message translates to:
  /// **'İlişki'**
  String get relationship;

  /// No description provided for @vocalCoach.
  ///
  /// In tr, this message translates to:
  /// **'Vokal hocası'**
  String get vocalCoach;

  /// No description provided for @danceCoach.
  ///
  /// In tr, this message translates to:
  /// **'Dans hocası'**
  String get danceCoach;

  /// No description provided for @dayLabel.
  ///
  /// In tr, this message translates to:
  /// **'{day}. GÜN'**
  String dayLabel(int day);

  /// No description provided for @castingSeason.
  ///
  /// In tr, this message translates to:
  /// **'CASTING • SEZON 01'**
  String get castingSeason;

  /// No description provided for @contestants.
  ///
  /// In tr, this message translates to:
  /// **'YARIŞMACILAR'**
  String get contestants;

  /// No description provided for @meetAllContestants.
  ///
  /// In tr, this message translates to:
  /// **'15 yarışmacıyı tanı. Final kadronu şimdiden düşünmeye başla.'**
  String get meetAllContestants;

  /// No description provided for @seenAllContestants.
  ///
  /// In tr, this message translates to:
  /// **'15 YARIŞMACIYI GÖRDÜM'**
  String get seenAllContestants;

  /// No description provided for @firstImpressionTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk izlenimin kimden yana?'**
  String get firstImpressionTitle;

  /// No description provided for @firstImpressionBody.
  ///
  /// In tr, this message translates to:
  /// **'15 yarışmacıyla tanıştın.\nŞimdilik sadece dikkatini çeken 5 kişiyi seç.'**
  String get firstImpressionBody;

  /// No description provided for @firstImpressionNote.
  ///
  /// In tr, this message translates to:
  /// **'Bu bir eleme değil. Fikrini daha sonra değiştirebilirsin.'**
  String get firstImpressionNote;

  /// No description provided for @radarCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} / 5 RADARDA'**
  String radarCount(int count);

  /// No description provided for @selectFive.
  ///
  /// In tr, this message translates to:
  /// **'5 KİŞİ SEÇ'**
  String get selectFive;

  /// No description provided for @radarReady.
  ///
  /// In tr, this message translates to:
  /// **'RADARIM HAZIR'**
  String get radarReady;

  /// No description provided for @radarLimit.
  ///
  /// In tr, this message translates to:
  /// **'Radarında sadece 5 kişi olabilir.'**
  String get radarLimit;

  /// No description provided for @enteredRadar.
  ///
  /// In tr, this message translates to:
  /// **'{name} radarına girdi ★'**
  String enteredRadar(String name);

  /// No description provided for @firstImpressionsComplete.
  ///
  /// In tr, this message translates to:
  /// **'İlk izlenimler tamam.'**
  String get firstImpressionsComplete;

  /// No description provided for @stageLightsChangeEverything.
  ///
  /// In tr, this message translates to:
  /// **'Ama sahne ışıkları yandığında her şey değişebilir.'**
  String get stageLightsChangeEverything;

  /// No description provided for @firstEvaluationStarting.
  ///
  /// In tr, this message translates to:
  /// **'İlk değerlendirme başlıyor.'**
  String get firstEvaluationStarting;

  /// No description provided for @firstEvaluation.
  ///
  /// In tr, this message translates to:
  /// **'İLK DEĞERLENDİRME'**
  String get firstEvaluation;

  /// No description provided for @firstImpressionRadar.
  ///
  /// In tr, this message translates to:
  /// **'İLK İZLENİM RADARI'**
  String get firstImpressionRadar;

  /// No description provided for @vocal.
  ///
  /// In tr, this message translates to:
  /// **'VOKAL'**
  String get vocal;

  /// No description provided for @dance.
  ///
  /// In tr, this message translates to:
  /// **'DANS'**
  String get dance;

  /// No description provided for @stage.
  ///
  /// In tr, this message translates to:
  /// **'SAHNE'**
  String get stage;

  /// No description provided for @goal.
  ///
  /// In tr, this message translates to:
  /// **'HEDEF'**
  String get goal;

  /// No description provided for @strength.
  ///
  /// In tr, this message translates to:
  /// **'GÜÇLÜ TARAF'**
  String get strength;

  /// No description provided for @attention.
  ///
  /// In tr, this message translates to:
  /// **'DİKKAT'**
  String get attention;

  /// No description provided for @removeFromRadar.
  ///
  /// In tr, this message translates to:
  /// **'RADARDAN ÇIKAR'**
  String get removeFromRadar;

  /// No description provided for @addToRadar.
  ///
  /// In tr, this message translates to:
  /// **'RADARA AL  ★'**
  String get addToRadar;

  /// No description provided for @producerDesk.
  ///
  /// In tr, this message translates to:
  /// **'YAPIMCI MASASI'**
  String get producerDesk;

  /// No description provided for @tabOverview.
  ///
  /// In tr, this message translates to:
  /// **'GÜNDEM'**
  String get tabOverview;

  /// No description provided for @tabTeams.
  ///
  /// In tr, this message translates to:
  /// **'TAKIMLAR'**
  String get tabTeams;

  /// No description provided for @tabBackstage.
  ///
  /// In tr, this message translates to:
  /// **'KULİS'**
  String get tabBackstage;

  /// No description provided for @backstagePreparing.
  ///
  /// In tr, this message translates to:
  /// **'KULİS HAZIRLANIYOR'**
  String get backstagePreparing;

  /// No description provided for @backstagePreparingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Günün gelişmeleri kısa süre içinde yapımcı masasına düşecek.'**
  String get backstagePreparingDesc;

  /// No description provided for @backstageInterview.
  ///
  /// In tr, this message translates to:
  /// **'KULİS RÖPORTAJI'**
  String get backstageInterview;

  /// No description provided for @applyThisDecision.
  ///
  /// In tr, this message translates to:
  /// **'BU KARARI UYGULA'**
  String get applyThisDecision;

  /// No description provided for @history.
  ///
  /// In tr, this message translates to:
  /// **'GEÇMİŞ'**
  String get history;

  /// No description provided for @captain.
  ///
  /// In tr, this message translates to:
  /// **'KAPTAN'**
  String get captain;

  /// No description provided for @roleCenter.
  ///
  /// In tr, this message translates to:
  /// **'CENTER'**
  String get roleCenter;

  /// No description provided for @roleMainVocal.
  ///
  /// In tr, this message translates to:
  /// **'ANA VOKAL'**
  String get roleMainVocal;

  /// No description provided for @roleDanceLead.
  ///
  /// In tr, this message translates to:
  /// **'DANS LİDERİ'**
  String get roleDanceLead;

  /// No description provided for @noEventScheduledToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün için planlanan kulis olayı yok.'**
  String get noEventScheduledToday;

  /// No description provided for @activeContestants.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Yarışmacı'**
  String get activeContestants;

  /// No description provided for @topMorale.
  ///
  /// In tr, this message translates to:
  /// **'En Yüksek Moral'**
  String get topMorale;

  /// No description provided for @topPopularity.
  ///
  /// In tr, this message translates to:
  /// **'En Popüler'**
  String get topPopularity;

  /// No description provided for @topBuzz.
  ///
  /// In tr, this message translates to:
  /// **'En Çok Konuşulan'**
  String get topBuzz;

  /// No description provided for @criticalEnergy.
  ///
  /// In tr, this message translates to:
  /// **'Kritik Enerji'**
  String get criticalEnergy;

  /// No description provided for @story.
  ///
  /// In tr, this message translates to:
  /// **'HİKÂYESİ'**
  String get story;

  /// No description provided for @personality.
  ///
  /// In tr, this message translates to:
  /// **'KİŞİLİK'**
  String get personality;

  /// No description provided for @specialTrait.
  ///
  /// In tr, this message translates to:
  /// **'ÖZEL ÖZELLİK'**
  String get specialTrait;

  /// No description provided for @risk.
  ///
  /// In tr, this message translates to:
  /// **'RİSK'**
  String get risk;

  /// No description provided for @talentReport.
  ///
  /// In tr, this message translates to:
  /// **'YETENEK RAPORU'**
  String get talentReport;

  /// No description provided for @role.
  ///
  /// In tr, this message translates to:
  /// **'ROL'**
  String get role;

  /// No description provided for @producerNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'YAPIMCI NOTU'**
  String get producerNoteLabel;

  /// No description provided for @potential.
  ///
  /// In tr, this message translates to:
  /// **'POTANSİYEL'**
  String get potential;

  /// No description provided for @ageWithCity.
  ///
  /// In tr, this message translates to:
  /// **'{age} • {city}'**
  String ageWithCity(int age, String city);

  /// No description provided for @stageTest.
  ///
  /// In tr, this message translates to:
  /// **'1. GÜN • SAHNE TESTİ'**
  String get stageTest;

  /// No description provided for @evalCompleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'İLK DEĞERLENDİRME\nTAMAMLANDI'**
  String get evalCompleteTitle;

  /// No description provided for @evalCompleteDesc.
  ///
  /// In tr, this message translates to:
  /// **'İlk sahne bazı beklentileri doğruladı.\nBazılarını ise tamamen değiştirdi.'**
  String get evalCompleteDesc;

  /// No description provided for @topFiveTonight.
  ///
  /// In tr, this message translates to:
  /// **'GECENİN İLK 5’İ'**
  String get topFiveTonight;

  /// No description provided for @outsideRadarSurprise.
  ///
  /// In tr, this message translates to:
  /// **'RADAR DIŞI SÜRPRİZ'**
  String get outsideRadarSurprise;

  /// No description provided for @radarTop.
  ///
  /// In tr, this message translates to:
  /// **'RADARIN EN YÜKSEĞİ'**
  String get radarTop;

  /// No description provided for @radarRisk.
  ///
  /// In tr, this message translates to:
  /// **'RADARIN RİSKLİSİ'**
  String get radarRisk;

  /// No description provided for @radarPerformance.
  ///
  /// In tr, this message translates to:
  /// **'RADAR PERFORMANSI'**
  String get radarPerformance;

  /// No description provided for @radarAverageScore.
  ///
  /// In tr, this message translates to:
  /// **'Radar ortalaması: {score}'**
  String radarAverageScore(String score);

  /// No description provided for @goToJuryRoom.
  ///
  /// In tr, this message translates to:
  /// **'JÜRİ ODASINA GEÇ'**
  String get goToJuryRoom;

  /// No description provided for @seeResults.
  ///
  /// In tr, this message translates to:
  /// **'SONUÇLARI GÖR'**
  String get seeResults;

  /// No description provided for @nextContestant.
  ///
  /// In tr, this message translates to:
  /// **'SONRAKİ YARIŞMACI'**
  String get nextContestant;

  /// No description provided for @radarPaidOff.
  ///
  /// In tr, this message translates to:
  /// **'★ Radar seçimin karşılığını verdi.'**
  String get radarPaidOff;

  /// No description provided for @radarDebatable.
  ///
  /// In tr, this message translates to:
  /// **'★ İlk izlenimin şimdilik tartışmalı.'**
  String get radarDebatable;

  /// No description provided for @notOnRadarThinkAgain.
  ///
  /// In tr, this message translates to:
  /// **'Onu radarına almamıştın.\nBelki tekrar düşünmelisin.'**
  String get notOnRadarThinkAgain;

  /// No description provided for @revealProgress.
  ///
  /// In tr, this message translates to:
  /// **'{current} / {total}'**
  String revealProgress(int current, int total);

  /// No description provided for @juryDecisionTitle.
  ///
  /// In tr, this message translates to:
  /// **'JÜRİ KARARI'**
  String get juryDecisionTitle;

  /// No description provided for @scoresDontSayAll.
  ///
  /// In tr, this message translates to:
  /// **'Puanlar her şeyi söylemez.'**
  String get scoresDontSayAll;

  /// No description provided for @juryIntroDesc.
  ///
  /// In tr, this message translates to:
  /// **'İlk değerlendirme tamamlandı.\nŞimdi jüri masası konuşuyor.'**
  String get juryIntroDesc;

  /// No description provided for @lowestFiveRisk.
  ///
  /// In tr, this message translates to:
  /// **'En düşük 5 puanı alan yarışmacı risk bölgesinde.'**
  String get lowestFiveRisk;

  /// No description provided for @oneDecisionIsYours.
  ///
  /// In tr, this message translates to:
  /// **'Ama bu gece bir karar sana ait.'**
  String get oneDecisionIsYours;

  /// No description provided for @viewRiskZone.
  ///
  /// In tr, this message translates to:
  /// **'RİSK BÖLGESİNİ GÖR'**
  String get viewRiskZone;

  /// No description provided for @safe.
  ///
  /// In tr, this message translates to:
  /// **'GÜVENDE'**
  String get safe;

  /// No description provided for @faceTheJury.
  ///
  /// In tr, this message translates to:
  /// **'JÜRİNİN KARŞISINA ÇIK'**
  String get faceTheJury;

  /// No description provided for @riskZone.
  ///
  /// In tr, this message translates to:
  /// **'RİSK BÖLGESİ'**
  String get riskZone;

  /// No description provided for @riskZoneDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu gece elenme riski taşıyan 5 yarışmacı:'**
  String get riskZoneDesc;

  /// No description provided for @protectOnePerson.
  ///
  /// In tr, this message translates to:
  /// **'BİR KİŞİYİ KORU'**
  String get protectOnePerson;

  /// No description provided for @confirmProtection.
  ///
  /// In tr, this message translates to:
  /// **'KORUMAYI ONAYLA'**
  String get confirmProtection;

  /// No description provided for @protectingContestant.
  ///
  /// In tr, this message translates to:
  /// **'{name}’Yİ KORUYORSUN'**
  String protectingContestant(String name);

  /// No description provided for @protectionWarning.
  ///
  /// In tr, this message translates to:
  /// **'{name} bu gece doğrudan güvende olacak.\nBu kararı daha sonra değiştiremezsin.'**
  String protectionWarning(String name);

  /// No description provided for @yesProtect.
  ///
  /// In tr, this message translates to:
  /// **'EVET, KORU'**
  String get yesProtect;

  /// No description provided for @goBack.
  ///
  /// In tr, this message translates to:
  /// **'GERİ DÖN'**
  String get goBack;

  /// No description provided for @producerRightUsed.
  ///
  /// In tr, this message translates to:
  /// **'YAPIMCI HAKKI KULLANILDI'**
  String get producerRightUsed;

  /// No description provided for @producerProtectedMsg.
  ///
  /// In tr, this message translates to:
  /// **'Yapımcı olarak {name}’yi korudun.\nDoğrudan bir sonraki güne geçti.'**
  String producerProtectedMsg(String name);

  /// No description provided for @jurySavedTop.
  ///
  /// In tr, this message translates to:
  /// **'Jüri en yüksek puana sahip adayı korudu.'**
  String get jurySavedTop;

  /// No description provided for @juryProtected.
  ///
  /// In tr, this message translates to:
  /// **'JÜRİ KORUDU'**
  String get juryProtected;

  /// No description provided for @goToLastChance.
  ///
  /// In tr, this message translates to:
  /// **'SON ŞANS SAHNESİNE GEÇ'**
  String get goToLastChance;

  /// No description provided for @juryDecisionSummaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'JÜRİ DEĞERLENDİRMESİ TAMAMLANDI'**
  String get juryDecisionSummaryTitle;

  /// No description provided for @juryDecisionSummaryDesc.
  ///
  /// In tr, this message translates to:
  /// **'Yapımcı hakkı ve jüri tercihi sonrası 3 aday son şans sahnesinde.'**
  String get juryDecisionSummaryDesc;

  /// No description provided for @lastChanceTitle.
  ///
  /// In tr, this message translates to:
  /// **'SON ŞANS SAHNESİ'**
  String get lastChanceTitle;

  /// No description provided for @threeContestantsOneFarewell.
  ///
  /// In tr, this message translates to:
  /// **'3 yarışmacı.\n1 veda.'**
  String get threeContestantsOneFarewell;

  /// No description provided for @lastChanceIntroDesc.
  ///
  /// In tr, this message translates to:
  /// **'Puanlar sıfırlanmadı ama her şey bu performansa bağlı.'**
  String get lastChanceIntroDesc;

  /// No description provided for @enterStage.
  ///
  /// In tr, this message translates to:
  /// **'SAHNEYE GEÇ'**
  String get enterStage;

  /// No description provided for @givingCoachingNote.
  ///
  /// In tr, this message translates to:
  /// **'{name}’YE SAHNE NOTU VERİYORSUN'**
  String givingCoachingNote(String name);

  /// No description provided for @coachingSingleWarning.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölümde yalnızca bir yarışmacıya müdahale edebilirsin.'**
  String get coachingSingleWarning;

  /// No description provided for @yesSelect.
  ///
  /// In tr, this message translates to:
  /// **'EVET, SEÇ'**
  String get yesSelect;

  /// No description provided for @coachingPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Bir yarışmacıya kritik sahne notu ver (+3 puan):'**
  String get coachingPrompt;

  /// No description provided for @noIntervention.
  ///
  /// In tr, this message translates to:
  /// **'MÜDAHALE ETMEDEN İZLE'**
  String get noIntervention;

  /// No description provided for @confirmChoice.
  ///
  /// In tr, this message translates to:
  /// **'TERCİHİ ONAYLA'**
  String get confirmChoice;

  /// No description provided for @performanceReveal.
  ///
  /// In tr, this message translates to:
  /// **'PERFORMANS DEĞERLENDİRMESİ'**
  String get performanceReveal;

  /// No description provided for @scoresCompared.
  ///
  /// In tr, this message translates to:
  /// **'PUANLAR KARŞILAŞTIRILIYOR'**
  String get scoresCompared;

  /// No description provided for @firstSafeContestant.
  ///
  /// In tr, this message translates to:
  /// **'GÜVENDE OLAN İLK İSİM'**
  String get firstSafeContestant;

  /// No description provided for @finalTwoTitle.
  ///
  /// In tr, this message translates to:
  /// **'SON İKİ YARIŞMACI'**
  String get finalTwoTitle;

  /// No description provided for @farewellTitle.
  ///
  /// In tr, this message translates to:
  /// **'VEDA ANI'**
  String get farewellTitle;

  /// No description provided for @farewellDesc.
  ///
  /// In tr, this message translates to:
  /// **'{name} yarışmaya veda etti.'**
  String farewellDesc(String name);

  /// No description provided for @coachedBadge.
  ///
  /// In tr, this message translates to:
  /// **'KOÇLUK DESTEĞİ ALDI (+3)'**
  String get coachedBadge;

  /// No description provided for @continueToRoster.
  ///
  /// In tr, this message translates to:
  /// **'KADRO GÜNCELLEMESİNE GEÇ'**
  String get continueToRoster;

  /// No description provided for @day1Complete.
  ///
  /// In tr, this message translates to:
  /// **'1. GÜN TAMAMLANDI'**
  String get day1Complete;

  /// No description provided for @activeRemainingCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} KİŞİ KALDI'**
  String activeRemainingCount(int count);

  /// No description provided for @firstDayLessonsDesc.
  ///
  /// In tr, this message translates to:
  /// **'İlk günün ardından kadro şekillenmeye başladı.\nŞimdi sıra takım görevinde.'**
  String get firstDayLessonsDesc;

  /// No description provided for @eliminatedMember.
  ///
  /// In tr, this message translates to:
  /// **'ELENEN YARIŞMACI'**
  String get eliminatedMember;

  /// No description provided for @activeRoster.
  ///
  /// In tr, this message translates to:
  /// **'DEVAM EDEN YARIŞMACILAR'**
  String get activeRoster;

  /// No description provided for @advanceToDay2.
  ///
  /// In tr, this message translates to:
  /// **'2. GÜNE GEÇ'**
  String get advanceToDay2;

  /// No description provided for @day2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. GÜN • GRUP GÖREVİ'**
  String get day2Title;

  /// No description provided for @groupTaskBriefing.
  ///
  /// In tr, this message translates to:
  /// **'Grup Görevi: Şarkı ve Uyum'**
  String get groupTaskBriefing;

  /// No description provided for @teamFormationTitle.
  ///
  /// In tr, this message translates to:
  /// **'TAKIM KURULUMU'**
  String get teamFormationTitle;

  /// No description provided for @teamA.
  ///
  /// In tr, this message translates to:
  /// **'A TAKIMI'**
  String get teamA;

  /// No description provided for @teamB.
  ///
  /// In tr, this message translates to:
  /// **'B TAKIMI'**
  String get teamB;

  /// No description provided for @autoFormTeams.
  ///
  /// In tr, this message translates to:
  /// **'OTOMATİK TAKIMLARI ONAYLA'**
  String get autoFormTeams;

  /// No description provided for @manualBuilder.
  ///
  /// In tr, this message translates to:
  /// **'MANUEL KADRO KUR'**
  String get manualBuilder;

  /// No description provided for @rehearsalTitle.
  ///
  /// In tr, this message translates to:
  /// **'PROVA ODASI'**
  String get rehearsalTitle;

  /// No description provided for @rehearsalCrisesTitle.
  ///
  /// In tr, this message translates to:
  /// **'PROVA KRİZİ'**
  String get rehearsalCrisesTitle;

  /// No description provided for @resolveCrisis.
  ///
  /// In tr, this message translates to:
  /// **'KRİZİ ÇÖZ'**
  String get resolveCrisis;

  /// No description provided for @groupStageTitle.
  ///
  /// In tr, this message translates to:
  /// **'GRUP SAHNESİ'**
  String get groupStageTitle;

  /// No description provided for @groupResultsTitle.
  ///
  /// In tr, this message translates to:
  /// **'GRUP SONUÇLARI'**
  String get groupResultsTitle;

  /// No description provided for @winningTeamImmune.
  ///
  /// In tr, this message translates to:
  /// **'KAZANAN TAKIM DOKUNULMAZ'**
  String get winningTeamImmune;

  /// No description provided for @juryTableTitle.
  ///
  /// In tr, this message translates to:
  /// **'JÜRİ MASASI'**
  String get juryTableTitle;

  /// No description provided for @duelTitle.
  ///
  /// In tr, this message translates to:
  /// **'İKİLİ DÜELLO'**
  String get duelTitle;

  /// No description provided for @duelWinner.
  ///
  /// In tr, this message translates to:
  /// **'DÜELLO KAZANANI'**
  String get duelWinner;

  /// No description provided for @duelElimination.
  ///
  /// In tr, this message translates to:
  /// **'DÜELLO ELEMESİ'**
  String get duelElimination;

  /// No description provided for @advanceToDay3.
  ///
  /// In tr, this message translates to:
  /// **'3. GÜNE GEÇ'**
  String get advanceToDay3;

  /// No description provided for @day3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. GÜN • İKON ŞARKILAR'**
  String get day3Title;

  /// No description provided for @iconStageBriefing.
  ///
  /// In tr, this message translates to:
  /// **'İkon Sahnesi'**
  String get iconStageBriefing;

  /// No description provided for @iconPerformanceResults.
  ///
  /// In tr, this message translates to:
  /// **'İkon Performans Sonuçları'**
  String get iconPerformanceResults;

  /// No description provided for @finalCutTitle.
  ///
  /// In tr, this message translates to:
  /// **'YARI FİNAL ELEMESİ'**
  String get finalCutTitle;

  /// No description provided for @advanceToDay4.
  ///
  /// In tr, this message translates to:
  /// **'4. GÜNE GEÇ'**
  String get advanceToDay4;

  /// No description provided for @day4Title.
  ///
  /// In tr, this message translates to:
  /// **'4. GÜN • POZİSYON SAVAŞI'**
  String get day4Title;

  /// No description provided for @positionBattleBriefing.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon Savaşı'**
  String get positionBattleBriefing;

  /// No description provided for @roomVocal.
  ///
  /// In tr, this message translates to:
  /// **'VOKAL ODASI'**
  String get roomVocal;

  /// No description provided for @roomDance.
  ///
  /// In tr, this message translates to:
  /// **'DANS ODASI'**
  String get roomDance;

  /// No description provided for @roomStage.
  ///
  /// In tr, this message translates to:
  /// **'SAHNE ODASI'**
  String get roomStage;

  /// No description provided for @positionBattleResults.
  ///
  /// In tr, this message translates to:
  /// **'Pozisyon Savaşı Sonuçları'**
  String get positionBattleResults;

  /// No description provided for @advanceToDay5.
  ///
  /// In tr, this message translates to:
  /// **'5. GÜNE GEÇ'**
  String get advanceToDay5;

  /// No description provided for @day5Title.
  ///
  /// In tr, this message translates to:
  /// **'5. GÜN • CANLI YAYIN'**
  String get day5Title;

  /// No description provided for @liveShowBriefing.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Yayın Gösterisi'**
  String get liveShowBriefing;

  /// No description provided for @broadcastDirection.
  ///
  /// In tr, this message translates to:
  /// **'YAYIN STRATEJİSİ'**
  String get broadcastDirection;

  /// No description provided for @liveShowResults.
  ///
  /// In tr, this message translates to:
  /// **'Canlı Yayın Sonuçları'**
  String get liveShowResults;

  /// No description provided for @advanceToGrandFinal.
  ///
  /// In tr, this message translates to:
  /// **'BÜYÜK FİNALE GEÇ'**
  String get advanceToGrandFinal;

  /// No description provided for @grandFinalTitle.
  ///
  /// In tr, this message translates to:
  /// **'BÜYÜK FİNAL'**
  String get grandFinalTitle;

  /// No description provided for @selectFinalFive.
  ///
  /// In tr, this message translates to:
  /// **'FİNAL 5’LİYİ SEÇ'**
  String get selectFinalFive;

  /// No description provided for @conceptSelection.
  ///
  /// In tr, this message translates to:
  /// **'ÇIKIŞ KONSEPTİ'**
  String get conceptSelection;

  /// No description provided for @groupNaming.
  ///
  /// In tr, this message translates to:
  /// **'GRUP ADINI KOY'**
  String get groupNaming;

  /// No description provided for @enterGroupName.
  ///
  /// In tr, this message translates to:
  /// **'Grup Adı Girin'**
  String get enterGroupName;

  /// No description provided for @confirmDebut.
  ///
  /// In tr, this message translates to:
  /// **'ÇIKIŞI ONAYLA'**
  String get confirmDebut;

  /// No description provided for @debutPoster.
  ///
  /// In tr, this message translates to:
  /// **'ÇIKIŞ POSTERİ'**
  String get debutPoster;

  /// No description provided for @seasonComplete.
  ///
  /// In tr, this message translates to:
  /// **'SEZON TAMAMLANDI'**
  String get seasonComplete;

  /// No description provided for @newSeason.
  ///
  /// In tr, this message translates to:
  /// **'YENİ SEZON'**
  String get newSeason;

  /// No description provided for @startNewSeason.
  ///
  /// In tr, this message translates to:
  /// **'YENİ SEZONA BAŞLA'**
  String get startNewSeason;

  /// No description provided for @scoreLabel.
  ///
  /// In tr, this message translates to:
  /// **'Puan: {score}'**
  String scoreLabel(int score);

  /// No description provided for @rankLabel.
  ///
  /// In tr, this message translates to:
  /// **'{rank}.'**
  String rankLabel(int rank);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
