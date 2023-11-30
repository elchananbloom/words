import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/pages/app_language_picker.dart';
import 'package:words/pages/app_localization_singleton.dart';
import 'package:words/pages/language_picker.dart';
import 'package:words/pages/my_home.dart';
import 'package:words/pages/user_language_picker.dart';
import 'package:words/providers/new_word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/utills/snack_bar.dart';

class SelectLanguage extends riverpod.ConsumerWidget {
  const SelectLanguage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final style = Theme.of(context).textTheme.headlineLarge;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
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
            child: Expanded(
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
                    // style: TextStyle(
                    //   fontSize: style!.fontSize,
                    //   fontWeight: style.fontWeight,
                    //   fontFamily: style.fontFamily,
                    //   // height: style.height,
                    //   letterSpacing: style.letterSpacing,
                    //   color: style.color,
                    // ),
                    style: Theme.of(context).textTheme.headlineLarge,
                    softWrap: true,
                    // maxLines: 3,
                    // overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Text(
                    AppLocalizations.of(context)!.chooseLanguage,
                    style: Theme.of(context).textTheme.headlineMedium,
                    softWrap: true,
                    textAlign: TextAlign.center,
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
                    softWrap: true,
                    textAlign: TextAlign.center,
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
                        SnackBarWidget.showSnackBar(
                          context,
                          appLocalizations.selectLanguage,
                        );
                      }
                    },
                    // style: ElevatedButton.styleFrom(
                    //   // primary: Colors.cyan,
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 40, vertical: 16),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(30.0),
                    //   ),
                    // ),
                    child: Text(
                      AppLocalizations.of(context)!.continueText,
                      style: Theme.of(context).textTheme.headlineSmall,
                      // style: const TextStyle(
                      //   fontSize: 20,
                      //   fontWeight: FontWeight.bold,
                      //   // color: Colors.white,
                      // ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
