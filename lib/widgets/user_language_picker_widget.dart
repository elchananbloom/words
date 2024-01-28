import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:words/widgets/snack_bar_widget.dart';

class UserLanguagePickerWidget extends riverpod.ConsumerStatefulWidget {
  const UserLanguagePickerWidget({
    Key? key,
    this.isUserLanguagePicker,
    this.refreshWordsCallback,
    this.setUserLanguageToLearn,
    this.setSelectedLanguage,
    this.isAppLang,
    this.isAddLanguageToLearn,
    this.wordsCount,
    this.setIsSelectedLanguage,
  }) : super(key: key);

  final bool? isUserLanguagePicker;
  final Function? refreshWordsCallback;
  final Function()? setUserLanguageToLearn;
  final Function(String)? setSelectedLanguage;
  final bool? isAppLang;
  final bool? isAddLanguageToLearn;
  final Function()? wordsCount;
  final Function(bool)? setIsSelectedLanguage;

  @override
  riverpod.ConsumerState<UserLanguagePickerWidget> createState() =>
      _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState
    extends riverpod.ConsumerState<UserLanguagePickerWidget> {
  String? flag;
  List<String> _userLanguages = [];
  String selectLanguage = '';
  String userLanguageToLearn = '';

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
    if (widget.isUserLanguagePicker!) {
      getUserLanguageToLearn().then((value) {
        setState(() {
          userLanguageToLearn = value;
          flag = L10n.getFlag(userLanguageToLearn);
        });
        getLanguages();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUserLanguagePicker!) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: flag,
          hint: null,
          menuMaxHeight: 180,
          icon: Container(width: 0),
          onChanged: (String? value) {
            handleAddLanguage(value, context);
            widget.wordsCount!();
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
                                onPressed: () async {
                                  SQLHelper.deleteLanguage(valueItem);
                                  getLanguages();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  widget.refreshWordsCallback!(
                                      userLanguageToLearn!);
                                  await SnackBarWidget.showSnackBar(
                                    context,
                                    AppLocalizations.of(context)!
                                        .languageDeleted(
                                      L10n.getLanguageName(context, valueItem),
                                    ),
                                  );
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: Colors.black),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else if (widget.isAppLang!) {
      // var systemLocale = Locale(Platform.localeName.split('_')[0]);
      // //
      // //check if system locale is supported
      // if (!L10n.isSupported(systemLocale)) {
      //   systemLocale = const Locale('en');
      // }

      // // flag = L10n.getFlag(systemLocale.languageCode);
      // //set default language
      // final provider = Provider.of<LocaleProvider>(context, listen: false);
      // provider.setLocale(systemLocale);
      // String languageCode = systemLocale.languageCode == 'he'
      //         ? 'iw'
      //         : systemLocale.languageCode;
      //     provider.setLocale(Locale(languageCode));
      //     SharedPreferences.getInstance().then((prefs) {
      //       prefs.setString('appLanguage', languageCode);
      //     });
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 1.5,
            color: Colors.black.withOpacity(0.5),
          ),
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.95),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: flag,
            hint: Text(AppLocalizations.of(context)!.selectLanguage,
                style: Theme.of(context).textTheme.headlineSmall!),
            menuMaxHeight: 400,
            onChanged: (String? value) {
              setState(() {
                flag = value!;
              });
              final provider =
                  Provider.of<LocaleProvider>(context, listen: false);
              String languageCode = L10n.getLangCodeFromFlag(value!) == 'he'
                  ? 'iw'
                  : L10n.getLangCodeFromFlag(value);
              provider.setLocale(Locale(languageCode));
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString('appLanguage', languageCode);
              });
              widget.setIsSelectedLanguage!(true);
            },
            items: L10n.supportedLanguages.map((valueItem) {
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
          ),
        ),
      );
    } else if (widget.isAddLanguageToLearn!) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 1.5,
            color: Colors.black.withOpacity(0.5),
          ),
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.95),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: flag,
            hint: Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            menuMaxHeight: 400,
            onChanged: (String? value) {
              setState(() {
                flag = value!;
              });
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString(
                    'userLanguageToLearn', L10n.getLangCodeFromFlag(value!));
              });
              widget.setIsSelectedLanguage!(true);
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
          ),
        ),
      );
    } else {
      return DropdownButton<String>(
        value: flag,
        hint: Text(
          AppLocalizations.of(context)!.selectLanguage,
          style: Theme.of(context).textTheme.headlineSmall,
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
      final newLangCode = L10n.getLangCodeFromFlag(value!);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('userLanguageToLearn', newLangCode);
      });
      widget.setUserLanguageToLearn!();
      widget.refreshWordsCallback!(newLangCode);
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
            refreshWordsCallback: widget.refreshWordsCallback,
            setUserLanguageToLearn: widget.setUserLanguageToLearn,
            setSelectedLanguage: setSelectedLanguage,
            isAddLanguageToLearn: false,
            isAppLang: false,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              if (selectLanguage != '') {
                SQLHelper.createLanguage(selectLanguage);
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('userLanguageToLearn', selectLanguage);
                });
                getLanguages();
                widget.setUserLanguageToLearn!();
                widget.refreshWordsCallback!(selectLanguage!);
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
