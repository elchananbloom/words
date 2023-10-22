import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/l10n.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:words/providers/new_word.dart';

class AddLanguagePickerWidget extends riverpod.ConsumerStatefulWidget {
  const AddLanguagePickerWidget({
    Key? key,
    required this.setSelectedLanguage,
    // required this.langProvider,
    // required this.isAppLang,
    // required this.isChangeLang,
    // required this.isWithCountry,
    // this.func,
  }) : super(key: key);

  final Function(String) setSelectedLanguage;

  // final riverpod.StateProvider<String> langProvider;
  // final bool isAppLang;
  // final bool isChangeLang;
  // final bool isWithCountry;
  // final Function? func;

  @override
  riverpod.ConsumerState<AddLanguagePickerWidget> createState() =>
      _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState
    extends riverpod.ConsumerState<AddLanguagePickerWidget> {
  String? flag;

  @override
  void initState() {
    super.initState();
    // SharedPreferences.getInstance().then((prefs) {
    //   if (prefs.getString('userLanguageToLearn') != null) {
    //     flag = L10n.getFlag(prefs.getString('userLanguageToLearn')!);
    //   }
    // });
    // if (ref.read(widget.langProvider.notifier).state != '') {
    //   flag = L10n.getFlag(ref.read(widget.langProvider.notifier).state);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: flag,
        hint: Text('Select Language'),
        icon: Container(width: 0),
        onChanged: (String? value) {
          setState(() {
            flag = value!;
          });
          // print('onChanged: $value');

          // if (widget.isAppLang) {
          //   final provider = Provider.of<LocaleProvider>(context, listen: false);
          //   print('value: $value');
          //   provider.setLocale(Locale(L10n.getLangCodeFromFlag(value!)));
          // }
          widget.setSelectedLanguage(L10n.getLangCodeFromFlag(value!));
          // SharedPreferences.getInstance().then((prefs) {
          //   prefs.setString(
          //       'userLanguageToLearn', L10n.getLangCodeFromFlag(value!));
          // });
          // ref.read(widget.langProvider.notifier).state =
          //     L10n.getLangCodeFromFlag(value!);
          // if (widget.isChangeLang) {
          // widget.func!(L10n.getLangCodeFromFlag(value!));
          // }
          // // provider.setLocale(Locale(value.toString()));
        },
        items: L10n.allLanguages.map((valueItem) {
          String a(String b) {
            // print('a: $b');
            return b;
          }

          return DropdownMenuItem<String>(
            value: a(L10n.getFlag(valueItem.languageCode)),
            child: Text(
              '${L10n.getFlag(valueItem.languageCode)}\t\t${L10n.getLanguageName(context, valueItem.languageCode)}',
              style: const TextStyle(fontSize: 24),
            ),
          );
        }).toList(),
      ),
    );
  }
}
