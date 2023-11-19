import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:words/l10n.dart';
import 'package:words/pages/app_localization_singleton.dart';
import 'package:words/pages/my_home.dart';
// import 'package:words/pages/my_home.dart';
import 'package:words/pages/select_language.dart';
import 'package:words/pages/theme.dart';
import 'package:words/providers/new_word.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/l10n.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'package:provider/provider.dart';
import 'package:words/providers/user_provider.dart';

class MainScreen extends riverpod.ConsumerWidget {
  const MainScreen(
      {required this.isUserRegistered,
      required this.userLanguageToLearn,
      required this.appLanguage,
      Key? key})
      : super(key: key);

  final bool isUserRegistered;
  final String? userLanguageToLearn;
  final String? appLanguage;
  @override
  Widget build(BuildContext context, ref) {
    // final user = ref.read(userProvider).asData?.value;
    // final isUserRegistered = user != null &&
    //     user.userLanguage != null && user.userLanguageToLearn != null;

    print('isUserRegistered: $isUserRegistered');

    return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        builder: (context, child) {
          // if(appLanguage != null) {
          //   print('appLanguageMain: $appLanguage');
          //   final provider = Provider.of<LocaleProvider>(context);
          //   provider.setLocale(Locale(appLanguage!));
          //   AppLocalizationsSingleton.setInstance(AppLocalizations.of(context)!);
          // }
          final provider = Provider.of<LocaleProvider>(context);
          Locale locale = provider.locale;
          if(appLanguage != null) {
            locale = Locale(appLanguage!);
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Words',
            theme: MyThemeData.lightTheme,
            locale: locale,
            supportedLocales: L10n.supportedLanguages,
            localizationsDelegates: const [
              LocaleNamesLocalizationsDelegate(),
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home:
                isUserRegistered ? const MyHomePage() : 
                const SelectLanguage(),
          );
        });
  }
}
