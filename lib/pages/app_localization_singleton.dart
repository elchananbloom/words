import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppLocalizationsSingleton {
  static AppLocalizations? _instance;

  static void setInstance(AppLocalizations instance) {
    _instance = instance;
  }

  static AppLocalizations? getInstance() {
    return _instance;
  }
}
