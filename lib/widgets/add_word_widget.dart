import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:translator/translator.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/l10n.dart';
import 'package:chaleno/chaleno.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:words/models/enums.dart';
import 'package:words/models/word/word.dart';
import 'package:words/providers/new_word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:core';

import 'package:words/widgets/snack_bar_widget.dart';

class AddWordWidget extends ConsumerStatefulWidget {
  const AddWordWidget(
      {required this.languageCodeToLearn,
      required this.refreshWordsCallback,
      required this.handleIsLoading,
      required this.manageDownloadImage,
      Key? key})
      : super(key: key);

  final String languageCodeToLearn;
  final Function(String lang, {String term}) refreshWordsCallback;
  final Function(bool isLoading) handleIsLoading;
  final Future<String> Function(String, bool, {String imageSearch})
      manageDownloadImage;

  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends ConsumerState<AddWordWidget> {
  final FocusNode _firstFocusNode = FocusNode();
  final FocusNode _secondFocusNode = FocusNode();
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  var isFirstFocused = false;
  var isSecondFocused = false;

  @override
  void initState() {
    super.initState();
    // Set the initial values.
    ref.read(newLangToLearnWordProvider.notifier).state = '';
    ref.read(newAppLangWordProvider.notifier).state = '';
    ref.read(newEnglishWordProvider.notifier).state = '';
    _firstFocusNode.addListener(() {
      if (_firstFocusNode.hasFocus) {
        setState(() {
          isFirstFocused = true;
        });
      } else {
        setState(() {
          isFirstFocused = false;
        });
      }
    });
    _secondFocusNode.addListener(() {
      if (_secondFocusNode.hasFocus) {
        setState(() {
          isSecondFocused = true;
        });
      } else {
        setState(() {
          isSecondFocused = false;
        });
      }
    });
  }

  String removeDiacritics(String input) {
    return input.replaceAll(RegExp(r'[\u0591-\u05C7]'), '');
  }

  void addWord(String languageCodeToLearn, String appLanguageCode) async {
    final engWord = ref.read(newEnglishWordProvider.notifier).state.trim();
    final appLanguageWord =
        removeDiacritics(ref.read(newAppLangWordProvider.notifier).state)
            .trim();
    final languageToLearnWord =
        removeDiacritics(ref.read(newLangToLearnWordProvider.notifier).state);
    //check if word already exists
    final wordExists = await SQLHelper.isWordExist(languageCodeToLearn,
        appLanguageWord, languageToLearnWord);
    if (wordExists) {
      //TODO add language
      // ignore: use_build_context_synchronously
      SnackBarWidget.showSnackBar(
        context,
        "word already exists"
        // AppLocalizations.of(context)!.wordAlreadyExists(
        //     L10n.getLanguageName(context, appLanguageCode),
        //     L10n.getLanguageName(context, languageCodeToLearn)),
      );
      ref.read(newEnglishWordProvider.notifier).state = '';
    ref.read(newAppLangWordProvider.notifier).state = '';
    ref.read(newLangToLearnWordProvider.notifier).state = '';

    _firstController.clear();
    _secondController.clear();
    FocusScope.of(context).unfocus();
      return;
    }
    String engSentence = '';
    var firstLangSentence;
    var secondLangSentence;
    try {
      final url =
          'https://context.reverso.net/translation/english-hebrew/$engWord';

      widget.handleIsLoading(true);
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
      engSentence = element?.text.trim() ?? '';

      final translator = GoogleTranslator();
      firstLangSentence = await translator.translate(engSentence,
          from: 'en',
          to: languageCodeToLearn == 'he' ? 'iw' : languageCodeToLearn);

      secondLangSentence = await translator.translate(engSentence,
          from: 'en', to: appLanguageCode);
    } catch (e) {
      print(e);
    }
    String filePathAndName =
        await widget.manageDownloadImage(engWord.toLowerCase(), false);
    var firstLangSentenceText = '';
    var secondLangSentenceText = '';
    try {
      firstLangSentenceText = firstLangSentence.text;
      secondLangSentenceText = secondLangSentence.text;
    } catch (e) {
      secondLangSentenceText = AppLocalizations.of(context)!.noSentenceFound;
      print(e);
    }

    final word = Word(
      language: languageCodeToLearn,
      word: {
        Language.appLanguageCode: appLanguageWord,
        Language.languageCodeToLearn: languageToLearnWord,
        Language.english: engWord,
      },
      sentence: {
        Language.appLanguageCode:
            removeDiacritics(secondLangSentenceText).trim(),
        Language.languageCodeToLearn:
            removeDiacritics(firstLangSentenceText).trim(),
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
      labelText: L10n.getLanguageName(context, languageCode),
    );
  }

  TextDirection getTextDirection(String languageCode) {
  // Check if the language code indicates RTL language
  if (languageCode.toLowerCase() == 'ar' || languageCode.toLowerCase() == 'iw') {
    // Arabic and Hebrew are RTL languages
    return TextDirection.rtl;
  } else {
    // All other languages are considered LTR
    return TextDirection.ltr;
  }
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
        Directionality(
          textDirection: getTextDirection(appLanguageCode),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 30,
                child: TextField(
                  controller: _firstController,
                  focusNode: _firstFocusNode,
                  decoration:
                      getWordDecoration(widget.languageCodeToLearn).copyWith(
                    suffixIcon: isFirstFocused
                        ? IconButton(
                            onPressed: () {
                              _firstController.clear();
                              ref
                                  .read(newLangToLearnWordProvider.notifier)
                                  .state = '';
                              FocusScope.of(context).unfocus();
                            },
                            icon: const Icon(
                              Icons.clear,
                              size: 15,
                            ),
                          )
                        : null,
                  ),
                  style: const TextStyle(
                    height: 1,
                  ),
                  onChanged: (value) {
                    ref.read(newLangToLearnWordProvider.notifier).state = value;
                  },
                  onEditingComplete: () async {
                    await onEditingCompleteFirstLanguage(appLanguageCode);
                  },
                ),
              ),
              const SizedBox(
                // height: 10,
                width: 20,
              ),
              SizedBox(
                width: 150,
                height: 30,
                child: TextField(
                  controller: _secondController,
                  focusNode: _secondFocusNode,
                  decoration: getWordDecoration(appLanguageCode).copyWith(
                    suffixIcon: isSecondFocused
                        ? IconButton(
                            onPressed: () {
                              _secondController.clear();
                              ref.read(newAppLangWordProvider.notifier).state =
                                  '';
                              FocusScope.of(context).unfocus();
                            },
                            icon: const Icon(
                              Icons.clear,
                              size: 15,
                            ),
                          )
                        : null,
                  ),
                  style: const TextStyle(
                    height: 1,
                  ),
                  onChanged: (value) {
                    ref.read(newAppLangWordProvider.notifier).state = value;
                  },
                  onEditingComplete: () async {
                    await onEditingCompleteSecondLanguage(appLanguageCode);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          // width: 150,
          height: 30,
          child: ElevatedButton(
            onPressed: () {
              handleAddWord(appLanguageCode);
            },
            style: Theme.of(context).elevatedButtonTheme.style,
            child: Text(
              AppLocalizations.of(context)!.addWord,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void handleAddWord(String appLanguageCode) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(ref.read(newLangToLearnWordProvider.notifier).state == '' ||
        ref.read(newAppLangWordProvider.notifier).state == '')) {
      addWord(widget.languageCodeToLearn, appLanguageCode);
    } else if (ref.read(newLangToLearnWordProvider.notifier).state != '') {
      await onEditingCompleteFirstLanguage(appLanguageCode);
      addWord(widget.languageCodeToLearn, appLanguageCode);
    } else if (ref.read(newAppLangWordProvider.notifier).state != '') {
      await onEditingCompleteSecondLanguage(appLanguageCode);
      addWord(widget.languageCodeToLearn, appLanguageCode);
    } else {
      SnackBarWidget.showSnackBar(
        context,
        AppLocalizations.of(context)!.pleaseFillBothFields(
            L10n.getLanguageName(context, appLanguageCode),
            L10n.getLanguageName(context, widget.languageCodeToLearn)),
      );
    }
  }

  Future<void> onEditingCompleteSecondLanguage(String appLanguageCode) async {
    if (ref.read(newLangToLearnWordProvider.notifier).state == '') {
      final appLanguageWord = ref.read(newAppLangWordProvider.notifier).state;
      final translator = GoogleTranslator();
      widget.handleIsLoading(true);
      final firstLangTranslation = await translator.translate(appLanguageWord,
          from: 'auto',
          to: widget.languageCodeToLearn == 'he'
              ? 'iw'
              : widget.languageCodeToLearn);
      final engTranslation =
          await translator.translate(appLanguageWord, from: 'auto', to: 'en');
      widget.handleIsLoading(false);
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
      widget.handleIsLoading(true);
      final secLangTranslation = await translator.translate(wordToLearn,
          from: 'auto', to: appLanguageCode);
      final engTranslation =
          await translator.translate(wordToLearn, from: 'auto', to: 'en');
      widget.handleIsLoading(false);
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
