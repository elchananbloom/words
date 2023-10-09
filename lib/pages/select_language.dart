import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:words/l10n.dart';
import 'package:words/models/enums.dart';
import 'package:words/pages/language_picker.dart';
import 'package:words/pages/my_home.dart';
import 'package:words/providers/new_word.dart';
import 'package:provider/provider.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLanguage extends riverpod.ConsumerWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.cyan,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Words',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Text(
            AppLocalizations.of(context)!.chooseLanguage,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 50),
          LanguagePickerWidget(
              langProvider: languageCodeToLearnProvider, isAppLang: false, isChangeLang: false),
          const SizedBox(width: 50),
          Text(
            AppLocalizations.of(context)!.chooseAppLanguage,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 50),
          LanguagePickerWidget(
              langProvider: secondLangProvider, isAppLang: true, isChangeLang: false),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              print('languageCodeToLearnProvider: ' +
                  ref.read(languageCodeToLearnProvider.notifier).state);
              print('secondLangProvider: ' +
                  ref.read(secondLangProvider.notifier).state);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
