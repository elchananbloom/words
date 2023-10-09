import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:words/l10n.dart';
// import 'package:words/pages/my_home.dart';
import 'package:words/pages/select_language.dart';
import 'package:words/providers/new_word.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/l10n.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';


import 'package:provider/provider.dart';

class MainScreen extends riverpod.ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {

    return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);

          return MaterialApp(
            title: 'Words',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            locale: provider.locale,
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              LocaleNamesLocalizationsDelegate(),
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SelectLanguage(),
          );
        });
  }
}
