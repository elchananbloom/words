import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/utills/app_localization_singleton.dart';
import 'package:words/pages/home_page.dart';
import 'package:words/widgets/user_language_picker_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/widgets/snack_bar_widget.dart';

class SelectLanguagePage extends riverpod.ConsumerStatefulWidget {
  SelectLanguagePage({
    super.key,
    required this.isSelectAppLanguage,
  });

  final bool isSelectAppLanguage;

  @override
  _SelectAppLanguageState createState() => _SelectAppLanguageState();
}

class _SelectAppLanguageState
    extends riverpod.ConsumerState<SelectLanguagePage> {
  bool isSelectedLanguage = false;

  void setIsSelectedLanguage(bool value) {
    setState(() {
      isSelectedLanguage = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    onAppLanguagePressed() async {
      final appLocalizations = AppLocalizations.of(context)!;
      AppLocalizationsSingleton.setInstance(appLocalizations);

      String? appLanguage = await SharedPreferences.getInstance().then((prefs) {
        return prefs.getString('appLanguage');
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isUserHalfRegistered', true);
      if (appLanguage != null && appLanguage != '') {
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SelectLanguagePage(
              isSelectAppLanguage: false,
            ),
          ),
          (route) =>
              true, // This condition makes sure no routes remain in the stack
        );
      } else {
        // ignore: use_build_context_synchronously
        SnackBarWidget.showSnackBar(
          context,
          appLocalizations.selectLanguage,
        );
      }
    }

    onAddLanguagePressed() async {
      final appLocalizations = AppLocalizations.of(context)!;
      String? userLanguageToLearn =
          await SharedPreferences.getInstance().then((prefs) {
        return prefs.getString('userLanguageToLearn');
      });
      if (userLanguageToLearn != null && userLanguageToLearn != '') {
        SQLHelper.createLanguage(userLanguageToLearn);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isUserRegistered', true);
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) =>
              false, // This condition makes sure no routes remain in the stack
        );
      } else {
        // ignore: use_build_context_synchronously
        SnackBarWidget.showSnackBar(
          context,
          appLocalizations.selectLanguage,
        );
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('lib/assets/images/background_flags.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.9),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              minWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.background.withOpacity(0.95),
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
                  Image.asset(
                    'lib/assets/images/app_logo.png',
                    width: 150,
                    height: 150,
                  ),
                  Text(
                    "Words",
                    style: Theme.of(context).textTheme.headlineLarge,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    widget.isSelectAppLanguage
                        ? AppLocalizations.of(context)!.myMotherToungueIs
                        : AppLocalizations.of(context)!.iWantToLearn,
                    style: Theme.of(context).textTheme.headlineMedium,
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  widget.isSelectAppLanguage
                      ? UserLanguagePickerWidget(
                          isUserLanguagePicker: false,
                          isAppLang: true,
                          setIsSelectedLanguage: setIsSelectedLanguage,
                        )
                      : UserLanguagePickerWidget(
                          isUserLanguagePicker: false,
                          isAppLang: false,
                          isAddLanguageToLearn: true,
                          setIsSelectedLanguage: setIsSelectedLanguage,
                        ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: isSelectedLanguage
                        ? widget.isSelectAppLanguage
                            ? onAppLanguagePressed
                            : onAddLanguagePressed
                        : null,
                    style: isSelectedLanguage
                        ? Theme.of(context).elevatedButtonTheme.style
                        : Theme.of(context).elevatedButtonTheme.style!.copyWith(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[300]!),
                            ),
                    child: Text(
                      AppLocalizations.of(context)!.continueText,
                      style: Theme.of(context).textTheme.headlineSmall,
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
