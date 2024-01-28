import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

class L10n {
  static final allLanguages = [
    const Locale('en'),
    const Locale('ko'),
    const Locale('iw'),
    const Locale('ar'),
    // const Locale('zh'),
    const Locale('ja'),
    const Locale('de'),
    const Locale('fr'),
    const Locale('es'),
    const Locale('it'),
    const Locale('ru'),
    const Locale('pt'),
    const Locale('hi'),
    const Locale('bn'),
    //tagalog
    const Locale('tl'),
  ];

  static final supportedLanguages = [
    const Locale('en'),
    const Locale('ko'),
    const Locale('iw'),
    const Locale('ar'),
    // const Locale('zh'),
    const Locale('ja'),
    const Locale('de'),
    const Locale('fr'),
    const Locale('es'),
    const Locale('it'),
    const Locale('ru'),
    const Locale('pt'),
    const Locale('hi'),
    const Locale('bn'),
    //tagalog
    const Locale('tl'),
  ];

  static String getFlag(String countryCode) {
    switch (countryCode) {
      case 'ko':
        return '🇰🇷';
      case 'en':
        return '🇺🇸';
      case 'he':
        return '🇮🇱';
      case 'ar':
        return '🇸🇦';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'de':
        return '🇩🇪';
      case 'fr':
        return '🇫🇷';
      case 'es':
        return '🇪🇸';
      case 'it':
        return '🇮🇹';
      case 'ru':
        return '🇷🇺';
      case 'pt':
        return '🇵🇹';
      case 'hi':
        return '🇮🇳';
      case 'bn':
        return '🇧🇩';
      case 'tl':
        return '🇵🇭';
      case '+':
        return '+';
      default:
        return 'no flag';
    }
  }

  static String getLangCodeFromFlag(String flag) {
    switch (flag) {
      case '🇰🇷':
        return 'ko';
      case '🇺🇸':
        return 'en';
      case '🇮🇱':
        return 'he';
      case '🇸🇦':
        return 'ar';
      case '🇨🇳':
        return 'zh';
      case '🇯🇵':
        return 'ja';
      case '🇩🇪':
        return 'de';
      case '🇫🇷':
        return 'fr';
      case '🇪🇸':
        return 'es';
      case '🇮🇹':
        return 'it';
      case '🇷🇺':
        return 'ru';
      case '🇵🇹':
        return 'pt';
      case '🇮🇳':
        return 'hi';
      case '🇧🇩':
        return 'bn';
      case '🇵🇭':
        return 'tl';

      default:
        return 'no flag';
    }
  }

  static String getLanguageName(BuildContext context, String countryCode) {
    if (countryCode == 'iw') {
      return 'עברית';
    }
    if(countryCode == ''){
      return '';
    }
    return LocaleNames.of(context)!.nameOf(countryCode)!;
  }

  static bool isSupported(Locale systemLocale) {
    //check if the system locale is supported by language codes
    return supportedLanguages
        .any((supportedLocale) => supportedLocale.languageCode == systemLocale.languageCode);
  }
}
