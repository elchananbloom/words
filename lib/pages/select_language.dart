import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/models/user.dart';
import 'package:words/pages/app_language_picker.dart';
import 'package:words/pages/app_localization_singleton.dart';
import 'package:words/pages/language_picker.dart';
import 'package:words/pages/my_home.dart';
import 'package:words/providers/new_word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLanguage extends riverpod.ConsumerWidget {
  const SelectLanguage({ Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      // backgroundColor: Colors.blue,
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8.0,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image.asset(
                //   'assets/app_logo.png',
                //   width: 150,
                //   height: 150,
                // ),
                const SizedBox(height: 30),
                // welcome to words text
                Text(
                  AppLocalizations.of(context)!.welcomeToWords,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // choose language to learn
                Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                LanguagePickerWidget(
                  // langProvider: languageCodeToLearnProvider,
                  // isAppLang: false,
                  // isChangeLang: false,
                  // isWithCountry: true,
                ),
                const SizedBox(height: 20),

                // choose app language
                Text(
                  AppLocalizations.of(context)!.chooseAppLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const AppLanguagePickerWidget(
                  // langProvider: secondLangProvider,
                  // isAppLang: true,
                  // isChangeLang: false,
                  // isWithCountry: true,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async{
                    // set app language singleton
                    final appLocalizations = AppLocalizations.of(context)!;
                    AppLocalizationsSingleton.setInstance(appLocalizations);

                    String? userLanguageToLearn = await SharedPreferences.getInstance().then((prefs) {
                      return prefs.getString('userLanguageToLearn');
                    });

                    // final userLanguageToLearn =
                    //     ref.read(languageCodeToLearnProvider.notifier).state;
                    // final userLanguage =
                    //     ref.read(secondLangProvider.notifier).state;
                    if (userLanguageToLearn != null && userLanguageToLearn != '') {
                    //   final user = User(
                    //     userLanguageToLearn: userLanguageToLearn,
                    //     userLanguage: userLanguage,
                    //   );
                    //   SQLHelper.createUser(user);
                      SQLHelper.createLanguage(userLanguageToLearn);
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool('isUserRegistered', true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            appLocalizations.selectLanguage,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.continueText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
