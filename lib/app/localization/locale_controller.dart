import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef LocalePreferenceReader = Future<String?> Function();
typedef LocalePreferenceWriter = Future<void> Function(String languageCode);

class LocaleController extends ChangeNotifier {
  LocaleController()
      : _preferences = null,
        _preferenceReader = null,
        _preferenceWriter = null;

  @visibleForTesting
  LocaleController.withPreferences(this._preferences)
      : _preferenceReader = null,
        _preferenceWriter = null;

  @visibleForTesting
  LocaleController.withPersistence({
    required LocalePreferenceReader read,
    required LocalePreferenceWriter write,
  })  : _preferences = null,
        _preferenceReader = read,
        _preferenceWriter = write;

  static const _preferenceKey = 'selectedLanguage';
  final SharedPreferences? _preferences;
  final LocalePreferenceReader? _preferenceReader;
  final LocalePreferenceWriter? _preferenceWriter;
  Locale? _locale;
  Object? _lastPersistenceError;

  Locale? get locale => _locale;
  Object? get lastPersistenceError => _lastPersistenceError;

  Future<void> restore() async {
    try {
      final languageCode = _preferenceReader != null
          ? await _preferenceReader()
          : (_preferences ?? await SharedPreferences.getInstance()).getString(
              _preferenceKey,
            );
      if (languageCode == 'tr' || languageCode == 'en') {
        _locale = Locale(languageCode!);
        notifyListeners();
      }
      _lastPersistenceError = null;
    } on MissingPluginException catch (error, stackTrace) {
      _reportPersistenceFailure(error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _reportPersistenceFailure(error, stackTrace);
    }
  }

  Future<void> select(Locale locale) async {
    if (locale.languageCode != 'tr' && locale.languageCode != 'en') return;
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      if (_preferenceWriter != null) {
        await _preferenceWriter(locale.languageCode);
      } else {
        final preferences =
            _preferences ?? await SharedPreferences.getInstance();
        await preferences.setString(_preferenceKey, locale.languageCode);
      }
      _lastPersistenceError = null;
    } on MissingPluginException catch (error, stackTrace) {
      _reportPersistenceFailure(error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _reportPersistenceFailure(error, stackTrace);
    }
  }

  void _reportPersistenceFailure(Object error, StackTrace stackTrace) {
    _lastPersistenceError = error;
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Yıldız Kadro localization',
        context: ErrorDescription('while persisting the selected locale'),
      ),
    );
  }
}
