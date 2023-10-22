import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/l10n.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:words/providers/new_word.dart';

class AppLanguagePickerWidget extends riverpod.ConsumerStatefulWidget {
  const AppLanguagePickerWidget({
    Key? key,
    // required this.langProvider,
    // required this.isAppLang,
    // required this.isChangeLang,
    // required this.isWithCountry,
    // this.func,
  }) : super(key: key);

  // final riverpod.StateProvider<String> langProvider;
  // final bool isAppLang;
  // final bool isChangeLang;
  // final bool isWithCountry;
  // final Function? func;

  @override
  riverpod.ConsumerState<AppLanguagePickerWidget> createState() =>
      _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState
    extends riverpod.ConsumerState<AppLanguagePickerWidget> {
  String? flag;

  @override
  void initState() {
    super.initState();
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
          final provider = Provider.of<LocaleProvider>(context, listen: false);
          print('value: $value');
          String languageCode = L10n.getLangCodeFromFlag(value!) =='he' ? 'iw' : L10n.getLangCodeFromFlag(value);
          provider.setLocale(Locale(languageCode));
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('appLanguage', languageCode);
          });
          // }
          // ref.read(widget.langProvider.notifier).state =
          //     L10n.getLangCodeFromFlag(value!);
          // if (widget.isChangeLang) {
          //   widget.func!(L10n.getLangCodeFromFlag(value));
          // }
          // // provider.setLocale(Locale(value.toString()));
        },
        items: L10n.supportedLanguages.map((valueItem) {
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
