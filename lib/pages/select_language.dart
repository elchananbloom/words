import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/models/user.dart';
import 'package:words/pages/app_language_picker.dart';
import 'package:words/pages/app_localization_singleton.dart';
import 'package:words/pages/language_picker.dart';
import 'package:words/pages/my_home.dart';
import 'package:words/pages/user_language_picker.dart';
import 'package:words/providers/new_word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLanguage extends riverpod.ConsumerWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.background,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
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
                Text(
                  AppLocalizations.of(context)!.welcomeToWords,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 30),

                Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                const UserLanguagePickerWidget(
                  isUserLanguagePicker: false,
                  isAppLang: false,
                  isAddLanguageToLearn: true,
                ),
                const SizedBox(height: 20),

                Text(
                  AppLocalizations.of(context)!.chooseAppLanguage,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                const UserLanguagePickerWidget(
                  isUserLanguagePicker: false,
                  isAppLang: true,
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    // set app language singleton
                    final appLocalizations = AppLocalizations.of(context)!;
                    AppLocalizationsSingleton.setInstance(appLocalizations);

                    String? userLanguageToLearn =
                        await SharedPreferences.getInstance().then((prefs) {
                      return prefs.getString('userLanguageToLearn');
                    });

                    if (userLanguageToLearn != null &&
                        userLanguageToLearn != '') {
                      SQLHelper.createLanguage(userLanguageToLearn);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('isUserRegistered', true);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ),
                        (route) =>
                            false, // This condition makes sure no routes remain in the stack
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
