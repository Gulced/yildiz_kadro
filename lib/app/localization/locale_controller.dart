import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController() : _preferences = null;

  @visibleForTesting
  LocaleController.withPreferences(this._preferences);

  static const _preferenceKey = 'selectedLanguage';
  final SharedPreferences? _preferences;
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> restore() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_preferenceKey);
    if (languageCode == 'tr' || languageCode == 'en') {
      _locale = Locale(languageCode!);
      notifyListeners();
    }
  }

  Future<void> select(Locale locale) async {
    if (locale.languageCode != 'tr' && locale.languageCode != 'en') return;
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, locale.languageCode);
  }
}
