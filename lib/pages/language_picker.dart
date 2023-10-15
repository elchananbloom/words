import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:words/l10n.dart';
import 'package:words/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:words/providers/new_word.dart';

class LanguagePickerWidget extends riverpod.ConsumerStatefulWidget {
  const LanguagePickerWidget(
      {Key? key,
      required this.langProvider,
      required this.isAppLang,
      required this.isChangeLang,
      this.func})
      : super(key: key);

  final riverpod.StateProvider<String> langProvider;
  final bool isAppLang;
  final bool isChangeLang;
  final Function? func;

  @override
  riverpod.ConsumerState<LanguagePickerWidget> createState() =>
      _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState
    extends riverpod.ConsumerState<LanguagePickerWidget> {
  String? flag;

  @override
  void initState() {
    super.initState();
    if (ref.read(widget.langProvider.notifier).state != '') {
      flag = L10n.getFlag(ref.read(widget.langProvider.notifier).state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: flag,
        hint: Text('Select Item'),
        icon: Container(width: 0),
        onChanged: (String? value) {
          setState(() {
            flag = value!;
          });
          // print('onChanged: $value');
    
          if (widget.isAppLang) {
            final provider = Provider.of<LocaleProvider>(context, listen: false);
            print('value: $value');
            provider.setLocale(Locale(L10n.getLangCodeFromFlag(value!)));
          }
          ref.read(widget.langProvider.notifier).state =
              L10n.getLangCodeFromFlag(value!);
          if (widget.isChangeLang) {
            widget.func!(L10n.getLangCodeFromFlag(value));
          }
          // // provider.setLocale(Locale(value.toString()));
        },
        items: L10n.all.map((valueItem) {
          String a(String b) {
            print('a: $b');
            return b;
          }
    
          return DropdownMenuItem<String>(
            value: a(L10n.getFlag(valueItem.languageCode)),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                L10n.getFlag(valueItem.languageCode),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );

    // return DropdownButtonHideUnderline(
    //   child: DropdownButton(
    //     value: locale,
    //     icon: Container(width: 12),
    //     items: L10n.all.map(
    //       (locale) {
    //         var lang = locale.languageCode;
    //             if (lang == 'he') {
    //               lang = 'iw';
    //             }
    //         final flag = L10n.getFlag(locale.languageCode);

    //         return DropdownMenuItem(
    //           value: locale,
    //           onTap: () {
    //             print('onTap: ${locale.languageCode}');

    //             ref.read(langProvider.notifier).state = lang;

    //             if (isAppLang) {
    //               final provider =
    //                   Provider.of<LocaleProvider>(context, listen: false);

    //               provider.setLocale(locale);
    //             }
    //           },
    //           child: Center(
    //             child: Text(
    //               flag,
    //               style: const TextStyle(fontSize: 32),
    //             ),
    //           ),
    //         );
    //       },
    //     ).toList(),
    //     onChanged: (_) {},
    //   ),
    // );
  }
}
