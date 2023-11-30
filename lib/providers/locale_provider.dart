import 'package:flutter/material.dart';
import 'package:words/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if(!L10n.allLanguages.contains(locale)){
      print('setLocale: $locale');
      return;
    }
    _locale = locale;
    print('setLocale: $locale');
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}