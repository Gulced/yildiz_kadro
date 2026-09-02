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
