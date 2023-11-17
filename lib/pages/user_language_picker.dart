import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/l10n.dart';
import 'package:words/pages/add_language_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserLanguagePickerWidget extends riverpod.ConsumerStatefulWidget {
  const UserLanguagePickerWidget({
    Key? key,
    required this.isUserLanguagePicker,
    required this.func,
    required this.setUserLanguageToLearn,
    this.setSelectedLanguage,
  }) : super(key: key);

  final bool isUserLanguagePicker;
  final Function func;
  final Function() setUserLanguageToLearn;
  final Function(String)? setSelectedLanguage;

  @override
  riverpod.ConsumerState<UserLanguagePickerWidget> createState() =>
      _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState
    extends riverpod.ConsumerState<UserLanguagePickerWidget> {
  String? flag;
  List<String> _userLanguages = [];
  String? selectLanguage;
  String? userLanguageToLearn;

  setSelectedLanguage(String languageCode) {
    setState(() {
      selectLanguage = languageCode;
    });
  }

  getLanguages() async {
    _userLanguages = await SQLHelper.getLanguages();
    _userLanguages.add('+');
  }

  Future<String> getUserLanguageToLearn() async {
    final String? languageCodeToLearn =
        await SharedPreferences.getInstance().then((prefs) {
      return prefs.getString('userLanguageToLearn');
    });
    return languageCodeToLearn!;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isUserLanguagePicker) {
      getUserLanguageToLearn().then((value) {
        setState(() {
          userLanguageToLearn = value;
          flag = L10n.getFlag(userLanguageToLearn!);
        });
        getLanguages();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUserLanguagePicker) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: flag,
          hint: null,
          menuMaxHeight: 180,
          icon: Container(width: 0),
          onChanged: (String? value) {
            handleAddLanguage(value, context);
          },
          items: _userLanguages.map((valueItem) {
            String a(String b) {
              return b;
            }

            return DropdownMenuItem<String>(
              value: a(L10n.getFlag(valueItem)),
              child: GestureDetector(
                onLongPress: () {
                  if (valueItem != '+' && valueItem != userLanguageToLearn) {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .deleteLanguageConfirmation(
                                  L10n.getLanguageName(context, valueItem),
                                ),
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: () {
                                  SQLHelper.deleteLanguage(valueItem);
                                  getLanguages();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      barrierDismissible: true,
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Text(
                    L10n.getFlag(valueItem),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return DropdownButton<String>(
        value: flag,
        hint: Text(
          AppLocalizations.of(context)!.selectLanguage,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
              ),
        ),
        menuMaxHeight: 400,
        onChanged: (String? value) {
          setState(() {
            flag = value!;
          });
          widget.setSelectedLanguage!(L10n.getLangCodeFromFlag(value!));
        },
        items: L10n.allLanguages.map((valueItem) {
          String a(String b) {
            return b;
          }

          return DropdownMenuItem<String>(
            value: a(L10n.getFlag(valueItem.languageCode)),
            child: Text(
              '${L10n.getFlag(valueItem.languageCode)}\t\t${L10n.getLanguageName(context, valueItem.languageCode)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
            ),
          );
        }).toList(),
      );
    }
  }

  void handleAddLanguage(String? value, BuildContext context) {
    if (value == '+') {
      showDialog(
        context: context,
        builder: (_) {
          return addLanguageWidget(context);
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
      widget.func(newLangCode);
      // }
      // // provider.setLocale(Locale(value.toString()));
    }
  }

  AlertDialog addLanguageWidget(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.chooseLanguage,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 40),
          UserLanguagePickerWidget(
            isUserLanguagePicker: false,
            func: widget.func,
            setUserLanguageToLearn: widget.setUserLanguageToLearn,
            setSelectedLanguage: setSelectedLanguage,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (selectLanguage != null && selectLanguage != '') {
                SQLHelper.createLanguage(selectLanguage!);
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('userLanguageToLearn', selectLanguage!);
                });
                getLanguages();
                widget.setUserLanguageToLearn();
                widget.func(selectLanguage);
                setState(() {
                  flag = L10n.getFlag(selectLanguage!);
                });
                Navigator.of(context).pop();
              }
            },
            child: Text(
              AppLocalizations.of(context)!.continueText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}
