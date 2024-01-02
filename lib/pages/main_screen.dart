import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
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

class MainScreen extends riverpod.ConsumerStatefulWidget {
  const MainScreen({
    required this.isUserRegistered,
    required this.userLanguageToLearn,
    required this.appLanguage,
    Key? key,
  }) : super(key: key);

  final bool isUserRegistered;
  final String? userLanguageToLearn;
  final String? appLanguage;

  static _MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainScreenState>();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends riverpod.ConsumerState<MainScreen> {

  late ThemeMode _theme;

  @override
  void initState() {
    super.initState();
    //get themeMode from shared preferences
    //-1: system, 0: dark, 1: light
    SharedPreferences.getInstance().then((prefs) {
      final themeMode = prefs.getInt('themeMode') ?? -1;
      setState(() {
        _theme = themeMode == 0 ? ThemeMode.dark : themeMode == 1 ? ThemeMode.light : ThemeMode.system;
      });
    });

    // _theme = ThemeMode.system;
  }

  get theme => _theme;

  handleChangeTheme() {
    print('handleChangeTheme');
    setState(() {
      _theme = _theme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('themeMode', _theme == ThemeMode.dark ? 0 : 1);
    });
  }


  @override
  Widget build(BuildContext context) {
    // final user = ref.read(userProvider).asData?.value;
    // final isUserRegistered = user != null &&
    //     user.userLanguage != null && user.userLanguageToLearn != null;

    // print('isUserRegistered: $isUserRegistered');

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
          if (widget.appLanguage != null) {
            locale = Locale(widget.appLanguage!);
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Words',
            theme: MyThemeData.lightTheme,
            darkTheme: MyThemeData.darkTheme,
            themeMode: _theme,
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
             widget.isUserRegistered
                ?  MyHomePage(
                )
                : 
                const SelectLanguage(),
          );
        });
  }
}
