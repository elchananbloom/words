import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixabay_picker/model/pixabay_media.dart';
import 'package:pixabay_picker/pixabay_picker.dart';
import 'package:translator/translator.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/l10n.dart';
import 'package:chaleno/chaleno.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:words/models/enums.dart';
import 'package:words/models/word/word.dart';
import 'package:words/providers/new_word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:core';

class AddWord extends ConsumerStatefulWidget {
  const AddWord(
      {required this.languageCodeToLearn,
      required this.refreshWordsCallback,
      required this.manageDownloadImage,
      Key? key})
      : super(key: key);

  final String languageCodeToLearn;
  final Function(String lang, {String term}) refreshWordsCallback;
  final Future<String> Function(String word,bool isEdit) manageDownloadImage;

  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends ConsumerState<AddWord> {
  final FocusNode _firstFocusNode = FocusNode();
  final FocusNode _secondFocusNode = FocusNode();
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  

  String removeDiacritics(String input) {
    return input.replaceAll(RegExp(r'[\u0591-\u05C7]'), '');
  }

  void addWord(String languageCodeToLearn, String appLanguageCode) async {
    final engWord = ref.read(newEnglishWordProvider.notifier).state;
    final url =
        'https://context.reverso.net/translation/english-hebrew/$engWord';

    final chaleno = await Chaleno().load(url);
    List<Result> results = chaleno!.getElementsByClassName('example');

    final res = results[0].html;

    final spans = res!.split('</span>');

    final eng = spans[0].split('<span class="text" lang="en">')[0];

    // Parse the HTML string
    final document = html_parser.parse(eng);

    // Find the relevant element by class name or tag, e.g., <span class="text">
    final element = document.querySelector('.text');

    // Extract the text content of the element and remove leading/trailing whitespace
    String engSentence = element?.text.trim() ?? '';

    final translator = GoogleTranslator();
    final firstLangSentence = await translator.translate(engSentence,
        from: 'en', to: languageCodeToLearn);

    final secondLangSentence = await translator.translate(engSentence,
        from: 'en', to: appLanguageCode);

    String filePathAndName = await widget.manageDownloadImage(engWord,false);

    final word = Word(
      language: languageCodeToLearn,
      word: {
        Language.appLanguageCode:
            removeDiacritics(ref.read(newAppLangWordProvider.notifier).state),
        Language.languageCodeToLearn: removeDiacritics(
            ref.read(newLangToLearnWordProvider.notifier).state),
        Language.english: engWord,
      },
      sentence: {
        Language.appLanguageCode: removeDiacritics(secondLangSentence.text),
        Language.languageCodeToLearn: removeDiacritics(firstLangSentence.text),
        Language.english: engSentence,
      },
      image: filePathAndName,
    );
    await SQLHelper.createWord(word);
    widget.refreshWordsCallback(languageCodeToLearn);
    ref.read(newEnglishWordProvider.notifier).state = '';
    ref.read(newAppLangWordProvider.notifier).state = '';
    ref.read(newLangToLearnWordProvider.notifier).state = '';

    _firstController.clear();
    _secondController.clear();
    FocusScope.of(context).unfocus();
  }

  



  InputDecoration getWordDecoration(String languageCode) {
    return InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      labelText: L10n.getLanguageName(context, languageCode),
      labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14)
    );
  }

  @override
  void dispose() {
    // Dispose of the focus nodes and controllers when the widget is disposed.
    _firstFocusNode.dispose();
    _secondFocusNode.dispose();
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguageCode = AppLocalizations.of(context)!.languageCode;

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 30,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _firstController,
                  focusNode: _firstFocusNode,
                  decoration: getWordDecoration(widget.languageCodeToLearn),
                  onChanged: (value) {
                    ref.read(newLangToLearnWordProvider.notifier).state = value;
                  },
                  onEditingComplete: () async {
                    await onEditingCompleteFirstLanguage(appLanguageCode);
                  },
                ),
              ),
            ),
            const SizedBox(
              // height: 10,
              width: 20,
            ),
            SizedBox(
              width: 150,
              height: 30,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _secondController,
                  focusNode: _secondFocusNode,
                  decoration: getWordDecoration(appLanguageCode),
                  onChanged: (value) {
                    ref.read(newAppLangWordProvider.notifier).state = value;
                  },
                  onEditingComplete: () async {
                    await onEditingCompleteSecondLanguage(appLanguageCode);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 150,
          height: 30,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ElevatedButton(
              onPressed: () {
                handleAddWord(appLanguageCode);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.addWord),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void handleAddWord(String appLanguageCode) {
    if (!(ref.read(newLangToLearnWordProvider.notifier).state == '' ||
        ref.read(newAppLangWordProvider.notifier).state == '')) {
      addWord(widget.languageCodeToLearn, appLanguageCode);
    }
  }

  Future<void> onEditingCompleteSecondLanguage(String appLanguageCode) async {
    if (ref.read(newLangToLearnWordProvider.notifier).state == '') {
      final appLanguageWord = ref.read(newAppLangWordProvider.notifier).state;
      final translator = GoogleTranslator();
      final firstLangTranslation = await translator.translate(appLanguageWord,
          from: 'auto', to: widget.languageCodeToLearn);
      final engTranslation =
          await translator.translate(appLanguageWord, from: 'auto', to: 'en');
      ref.read(newLangToLearnWordProvider.notifier).state =
          removeDiacritics(firstLangTranslation.text);
      ref.read(newEnglishWordProvider.notifier).state = engTranslation.text;
      _firstController.text = removeDiacritics(firstLangTranslation.text);
      // Move the focus to the first TextField when "Enter" is pressed.
      FocusScope.of(context).requestFocus(_firstFocusNode);
    } else {
      handleAddWord(appLanguageCode);
    }
  }

  Future<void> onEditingCompleteFirstLanguage(String appLanguageCode) async {
    if (ref.read(newAppLangWordProvider.notifier).state == '') {
      final wordToLearn = ref.read(newLangToLearnWordProvider.notifier).state;
      final translator = GoogleTranslator();
      final secLangTranslation = await translator.translate(wordToLearn,
          from: 'auto', to: appLanguageCode);
      final engTranslation =
          await translator.translate(wordToLearn, from: 'auto', to: 'en');
      ref.read(newEnglishWordProvider.notifier).state = engTranslation.text;

      ref.read(newAppLangWordProvider.notifier).state =
          removeDiacritics(secLangTranslation.text);
      _secondController.text = removeDiacritics(secLangTranslation.text);
      // Move the focus to the second TextField when "Enter" is pressed.
      FocusScope.of(context).requestFocus(_secondFocusNode);
    } else {
      handleAddWord(appLanguageCode);
    }
  }
}

// class KoreanTextField extends StatelessWidget {
//   const KoreanTextField(
//       {super.key,
//       required TextEditingController firstController,
//       required FocusNode firstFocusNode,
//       required this.ref,
//       required TextEditingController secondController,
//       required FocusNode secondFocusNode,
//       required String languageCodeToLearn,
//       required String appLanguageCode})
//       : _firstController = firstController,
//         _firstFocusNode = firstFocusNode,
//         _secondController = secondController,
//         _secondFocusNode = secondFocusNode,
//         _languageCodeToLearn = languageCodeToLearn,
//         _appLanguageCode = appLanguageCode;

//   final TextEditingController _firstController;
//   final FocusNode _firstFocusNode;
//   final WidgetRef ref;
//   final TextEditingController _secondController;
//   final FocusNode _secondFocusNode;
//   final String _languageCodeToLearn;
//   final String _appLanguageCode;

//   @override
//   Widget build(BuildContext context) {
//     return;
//   }
// }
