import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/l10n/app_localizations.dart';
import 'package:yildiz_kadro/l10n/app_localizations_tr.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n {
    final localized = Localizations.of<AppLocalizations>(
      this,
      AppLocalizations,
    );
    if (localized != null) return localized;
    // Widgets rendered in isolation (for example component tests) do not have
    // the app delegate above them. Preserve the product's legacy Turkish
    // default in that narrow case; the real app always supplies a delegate.
    return AppLocalizationsTr();
  }
}
