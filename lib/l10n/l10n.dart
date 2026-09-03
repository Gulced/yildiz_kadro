import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/l10n/app_localizations.dart';
import 'package:yildiz_kadro/l10n/app_localizations_en.dart';
import 'package:yildiz_kadro/l10n/app_localizations_tr.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n {
    final localized = Localizations.of<AppLocalizations>(
      this,
      AppLocalizations,
    );
    if (localized != null) return localized;
    final languageCode = Localizations.maybeLocaleOf(this)?.languageCode;
    return languageCode == 'en' ? AppLocalizationsEn() : AppLocalizationsTr();
  }

  bool get isEnglish {
    return Localizations.localeOf(this).languageCode == 'en';
  }
}

bool isAppEnglish(BuildContext? context) =>
    context != null && Localizations.localeOf(context).languageCode == 'en';
