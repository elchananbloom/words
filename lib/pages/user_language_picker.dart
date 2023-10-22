import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/l10n.dart';
import 'package:words/models/user.dart';
import 'package:words/pages/add_language_picker.dart';
import 'package:words/pages/app_localization_singleton.dart';
import 'package:words/pages/language_picker.dart';
import 'package:words/providers/new_word.dart';
import 'package:words/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserLanguagePickerWidget extends riverpod.ConsumerStatefulWidget {
  const UserLanguagePickerWidget({
    Key? key,
    required this.isChangeLang,
    this.func,
    required this.setUserLanguageToLearn,
  }) : super(key: key);

  final bool isChangeLang;
  final Function? func;
  final Function() setUserLanguageToLearn;

  @override
  riverpod.ConsumerState<UserLanguagePickerWidget> createState() =>
      _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState
    extends riverpod.ConsumerState<UserLanguagePickerWidget> {
  String? flag;
  List<String> _userLanguages = [];
  // late User user;
  String? selectLanguage;
  String? userLanguageToLearn;
  // final _userLanguagesLocale =

  setSelectedLanguage(String languageCode) {
    setState(() {
      selectLanguage = languageCode;
    });
  }

  getLanguages() async {
    _userLanguages = await SQLHelper.getLanguages();
    _userLanguages.add('+');

    print('_userLanguages: $_userLanguages');
  }

  Future<String> getUserLanguageToLearn() async {
    final String? languageCodeToLearn =
        await SharedPreferences.getInstance().then((prefs) {
      return prefs.getString('userLanguageToLearn');
    });
    print('languageCodeToLearnUser: $languageCodeToLearn');
    return languageCodeToLearn!;
  }

  @override
  void initState() {
    super.initState();
    print('initState');
    // user = ref.read(userProvider).asData!.value;
    // print('userLanguageToLearn: ${user.userLanguageToLearn}');
    getUserLanguageToLearn().then((value) {
      setState(() {
        userLanguageToLearn = value;
        print('userLanguageToLearnInit: $userLanguageToLearn');
        flag = L10n.getFlag(userLanguageToLearn!);
      });
      getLanguages();
    });

    print('_userLanguages: $_userLanguages');
    // _userLanguagesLocale = _userLanguages.map((e) => Locale(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: flag,
        // hint: Text(AppLocalizationsSingleton.getInstance()!.selectLanguage),
        hint: Text(''),
        icon: Container(width: 25),
        onChanged: (String? value) {
          if (value == '+') {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.chooseLanguage,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AddLanguagePickerWidget(
                        setSelectedLanguage: setSelectedLanguage,
                        // langProvider: languageCodeToLearnProvider,
                        // isAppLang: false,
                        // isChangeLang: false,
                        // isWithCountry: true,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          // final userLanguageToLearn = ref
                          //     .read(languageCodeToLearnProvider.notifier)
                          //     .state;
                          // final oldUser = ref.read(userProvider).asData!.value;

                          if (selectLanguage != null && selectLanguage != '') {
                            SQLHelper.createLanguage(selectLanguage!);

                            // userLanguageToLearn = newLangCode;
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString(
                                  'userLanguageToLearn', selectLanguage!);
                            });
                            getLanguages();
                            widget.setUserLanguageToLearn();
                            widget.func!(selectLanguage);
                            setState(() {
                              print('in setState');
                              flag = L10n.getFlag(selectLanguage!);
                            });
                            Navigator.of(context).pop();
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              barrierDismissible: true,
            );
            return;
          } else {
            setState(() {
              flag = value!;
              userLanguageToLearn = L10n.getLangCodeFromFlag(value);
            });
            // print('onChanged: $value');

            final newLangCode = L10n.getLangCodeFromFlag(value!);
            // userLanguageToLearn = newLangCode;
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('userLanguageToLearn', newLangCode);
            });
            widget.setUserLanguageToLearn();
            // SQLHelper.updateUser(user);
            // if (widget.isChangeLang) {
            widget.func!(newLangCode);
            // }
            // // provider.setLocale(Locale(value.toString()));
          }
        },
        items: _userLanguages.map((valueItem) {
          String a(String b) {
            // print('a: $b');
            return b;
          }

          return DropdownMenuItem<String>(
            value: a(L10n.getFlag(valueItem)),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                L10n.getFlag(valueItem),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
