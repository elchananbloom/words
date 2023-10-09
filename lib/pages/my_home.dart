import 'dart:io';
import 'package:flutter/material.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/models/enums.dart';
import 'package:words/pages/language_picker.dart';
import 'package:words/utills/word_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:words/providers/new_word.dart';
import 'package:words/models/word/word.dart';
import 'package:translator/translator.dart';
import 'package:chaleno/chaleno.dart';
import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart' as html_dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
// import 'package:brain_fusion/brain_fusion.dart';
// import 'package:html/dom.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/l10n.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  // const MyHomePage({Key? key}) : super(key: key);
  List<Word> _words = [];
  bool _isLouding = true;

  final FocusNode _firstFocusNode = FocusNode();
  final FocusNode _secondFocusNode = FocusNode();
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();

  void _refreshWords(String lang) async {
    final data = await SQLHelper.getWords(lang);
    setState(() {
      _words = data;
      _isLouding = false;
    });
    print('data: $data');
  }

  void refreshWordsCallback(String lang) {
    _refreshWords(lang);
  }

  @override
  void initState() {
    super.initState();
    print('initState: MyHomePage');
    final langCodeToLearn =
        ref.read(languageCodeToLearnProvider.notifier).state;
    print('langCodeToLearn: $langCodeToLearn');
    _refreshWords(langCodeToLearn);
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
    final languageCodeToLearn =
        ref.read(languageCodeToLearnProvider.notifier).state;
    final appLanguageCode = AppLocalizations.of(context)!.languageCode;
    print('appLanguageCode: $appLanguageCode');
    // final second_lang = ref.read(secondLangProvider.notifier).state;
    // final fl = Locale(first_lang).languageCode;
    // final sl = AppLocalizations.of(context)!.languageCode;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.cyan,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Words',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Column(
          children: [
            LanguagePickerWidget(
                langProvider: languageCodeToLearnProvider,
                isAppLang: false,
                isChangeLang: true,
                func: refreshWordsCallback),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              width: 300,
              height: 30,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: KoreanTextField(
                  firstController: _firstController,
                  firstFocusNode: _firstFocusNode,
                  ref: ref,
                  secondController: _secondController,
                  secondFocusNode: _secondFocusNode,
                  languageCodeToLearn: languageCodeToLearn,
                  appLanguageCode: appLanguageCode,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 300,
              height: 30,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _secondController,
                  focusNode: _secondFocusNode,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText:
                        L10n.getLanguageName(context, appLanguageCode) ?? '',
                  ),
                  onChanged: (value) {
                    ref.read(newSecondLangProvider.notifier).state = value;
                  },
                  onEditingComplete: () {
                    addWord(context, languageCodeToLearn, appLanguageCode);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              height: 30,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ElevatedButton(
                  onPressed: () {
                    addWord(context, languageCodeToLearn, appLanguageCode);
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
            Expanded(
              child: ListView.builder(
                itemCount: _words.length,
                itemBuilder: (BuildContext context, int index) {
                  return WordCard(
                    word: _words[index],
                    callback: refreshWordsCallback,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> getImageByDom(String word) async {
    final Map<String, String> headers = {
      HttpHeaders.userAgentHeader:
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36'
    };
    var uri = Uri.parse(
        'https://www.google.com.pk/search?q=$word&tbm=isch&ved=2ahUKEwiK5_jmqt_uAhWE4oUKHSH-DRYQ2-cCegQIABAA');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != HttpStatus.ok) {
      return '';
    }

    var document = parse(response.body);

    late final docStr = document.outerHtml;

    RegExp imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"');

    // Find all matches in the HTML string.
    Iterable<Match> matches = imgRegExp.allMatches(docStr);

    // Extract and print the src attribute values
    List<String?> imgSrcList = matches.map((match) => match.group(1)).toList();

    return imgSrcList[15];
  }

  void addWord(BuildContext context, String languageCodeToLearn,
      String appLanguageCode) async {
    final engWord = ref.read(newEProvider.notifier).state;
    final url =
        'https://context.reverso.net/translation/english-hebrew/$engWord';

    final chaleno = await Chaleno().load(url);
    List<Result> results = chaleno!.getElementsByClassName('example');

    final res = results[0].html;

    final spans = res!.split('</span>');

    print('spans: ${spans[0]}');

    // final secLang = spans[2].split('<span class="text" lang="en">')[1];

    final eng = spans[0].split('<span class="text" lang="en">')[0];

    // RegExp regex = RegExp(r'[א-ת]+');

    // // Find all matches in the input string.
    // Iterable<Match> matches = regex.allMatches(secLang);

    // // Extract and print the Hebrew letters in the same order.
    // List<String?> hebrewLetters =
    //     matches.map((match) => match.group(0)).toList();

    // String hebrewSentence = hebrewLetters.join(' ');
    // print(hebrew);

    // Parse the HTML string
    final document = html_parser.parse(eng);

    // Find the relevant element by class name or tag, e.g., <span class="text">
    final element = document.querySelector('.text');

    // Extract the text content of the element and remove leading/trailing whitespace
    String engSentence = element?.text.trim() ?? '';

    // Print the extracted sentence
    final translator = GoogleTranslator();
    final firstLangSentence = await translator.translate(engSentence,
        from: 'en', to: languageCodeToLearn);

    final secondLangSentence = await translator.translate(engSentence,
        from: 'en', to: appLanguageCode);

    final img = await getImageByDom(engWord);

    final word = Word(
      language: languageCodeToLearn,
      word: {
        Language.appLanguageCode:
            ref.read(newSecondLangProvider.notifier).state,
        Language.languageCodeToLearn:
            ref.read(newFirstLangProvider.notifier).state,
        Language.english: ref.read(newEProvider.notifier).state,
      },
      sentence: {
        Language.appLanguageCode: secondLangSentence.text,
        Language.languageCodeToLearn: firstLangSentence.text,
        Language.english: engSentence,
      },
      image: img,
    );
    SQLHelper.createWord(word);

    _refreshWords(languageCodeToLearn);
    _firstController.clear();
    _secondController.clear();
    FocusScope.of(context).unfocus();
  }
}

class KoreanTextField extends StatelessWidget {
  const KoreanTextField(
      {super.key,
      required TextEditingController firstController,
      required FocusNode firstFocusNode,
      required this.ref,
      required TextEditingController secondController,
      required FocusNode secondFocusNode,
      required String languageCodeToLearn,
      required String appLanguageCode})
      : _firstController = firstController,
        _firstFocusNode = firstFocusNode,
        _secondController = secondController,
        _secondFocusNode = secondFocusNode,
        _languageCodeToLearn = languageCodeToLearn,
        _appLanguageCode = appLanguageCode;

  final TextEditingController _firstController;
  final FocusNode _firstFocusNode;
  final WidgetRef ref;
  final TextEditingController _secondController;
  final FocusNode _secondFocusNode;
  final String _languageCodeToLearn;
  final String _appLanguageCode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _firstController,
      focusNode: _firstFocusNode,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: L10n.getLanguageName(context, _languageCodeToLearn)),
      onChanged: (value) {
        ref.read(newFirstLangProvider.notifier).state = value;
      },
      onEditingComplete: () async {
        final kWord = ref.read(newFirstLangProvider.notifier).state;
        final translator = GoogleTranslator();
        final secLangTranslation = await translator.translate(kWord,
            from: _languageCodeToLearn, to: _appLanguageCode);
        final engTranslation = await translator.translate(kWord,
            from: _languageCodeToLearn, to: 'en');
        ref.read(newEProvider.notifier).state = engTranslation.text;

        ref.read(newSecondLangProvider.notifier).state =
            secLangTranslation.text;
        _secondController.text = secLangTranslation.text;
        print('translation: ${secLangTranslation.text}');

        // Move the focus to the second TextField when "Enter" is pressed.
        FocusScope.of(context).requestFocus(_secondFocusNode);
      },
    );
  }
}
