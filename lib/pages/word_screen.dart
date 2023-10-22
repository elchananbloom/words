import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/l10n.dart';
import 'package:words/models/word/word.dart';
import 'package:words/models/enums.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/providers/new_word.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';

import 'package:words/providers/user_provider.dart';

class WordScreen extends ConsumerStatefulWidget {
  const WordScreen({Key? key, required this.word, required this.callback})
      : super(key: key);

  final Word word;
  final Function callback;

  @override
  ConsumerState<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends ConsumerState<WordScreen> {
  late Word word;
  late Function callback;
  String? userLanguageToLearn;

  @override
  void initState() {
    super.initState();
    word = widget.word;
    callback = widget.callback;
    getUserLanguageToLearn().then((value) {
      setState(() {
        userLanguageToLearn = value;
      });
    });
  }

  Future<String> getUserLanguageToLearn() async {
    final String? languageCodeToLearn =
        await SharedPreferences.getInstance().then((prefs) {
      return prefs.getString('userLanguageToLearn');
    });
    return languageCodeToLearn!;
  }

  @override
  Widget build(BuildContext context) {
    final _firstWordController = TextEditingController();
    final _secondWordController = TextEditingController();
    final _firstSentenceController = TextEditingController();
    final _secondSentenceController = TextEditingController();
    final _imageController = TextEditingController();

    // final user = ref.read(userProvider).asData!.value;

    final languageCodeToLearn = userLanguageToLearn!;
    // ref.read(languageCodeToLearnProvider.notifier).state;
    final appLanguageCode = AppLocalizations.of(context)!.languageCode;

    // final first_lang = ref.read(firstLangProvider.notifier).state;
    // final second_lang = ref.read(secondLangProvider.notifier).state;

    Future<void> _updateWord(int id, Word word) async {
      final updatedWord = Word(
        word: <Language, String>{
          Language.english: _firstWordController.text,
          Language.appLanguageCode: _secondWordController.text,
          Language.languageCodeToLearn: _firstWordController.text,
        },
        sentence: <Language, String>{
          Language.english: _firstSentenceController.text,
          Language.appLanguageCode: _secondSentenceController.text,
          Language.languageCodeToLearn: _firstSentenceController.text,
        },
        image: _imageController.text,
      );
      print('id: $id');
      await SQLHelper.updateWord(id, updatedWord);
      callback();
      Navigator.of(context).pop();
    }

    Future<void> _deleteWord(int id) async {
      await SQLHelper.deleteWord(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('המילה נמחקה בהצלחה'),
        ),
      );
      callback();
      Navigator.of(context).pop();
    }

    void _showForm(int? id) async {
      if (id != null) {
        _firstWordController.text = word.word![Language.languageCodeToLearn]!;
        _secondWordController.text = word.word![Language.appLanguageCode]!;
        _firstSentenceController.text =
            word.sentence![Language.languageCodeToLearn]!;
        _secondSentenceController.text =
            word.sentence![Language.appLanguageCode]!;
        _imageController.text = word.image!;
      }
      print('id: $id');
      showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _firstWordController,
                decoration: InputDecoration(
                  labelText: L10n.getLanguageName(context, languageCodeToLearn),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _secondWordController,
                decoration: InputDecoration(
                  labelText: L10n.getLanguageName(context, appLanguageCode),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _firstSentenceController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                      .sentenceInLanguage(languageCodeToLearn),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _secondSentenceController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                      .sentenceInLanguage(appLanguageCode),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _imageController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.image,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (id != null) {
                    await _updateWord(id, word);
                  }

                  _firstWordController.text = '';
                  _secondWordController.text = '';
                  _firstSentenceController.text = '';
                  _secondSentenceController.text = '';
                  _imageController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text('עדכן מילה'),
              ),
            ],
          ),
        ),
      );
    }

    print('word.image: ${word.image}');
    // final imgSrc = word.image!.split(',')[1];

    // print('imgSrc: $imgSrc');

    // final decodedBytes = base64Decode(imgSrc);
    // print('decodedBytes: $decodedBytes');
    // const strUri = 'https://thumbor.forbes.com/thumbor/fit-in/900x510/https://www.forbes.com/advisor/wp-content/uploads/2023/07/top-20-small-dog-breeds.jpeg.jpg';
    final imgWidget = Image.network(word.image!);
    // Create an Image widget
    // final imageWidget = Image.memory(
    //   decodedBytes,
    //   width: 200,
    //   height: 200,
    //   fit: BoxFit.cover,);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Container(
          //   child: imgWidget,
          //   width: 200,
          //   height: 200,

          // ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: imgWidget.image,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fitHeight,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showForm(word.id),
                  icon: const Icon(Icons.edit),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    _deleteWord(word.id!);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(
                word.word![Language.languageCodeToLearn]!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 0.12,
                  letterSpacing: 0.50,
                ),
              ),
              const SizedBox(
                width: 100,
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  '${L10n.getLanguageName(context, languageCodeToLearn)}:',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.12,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(
                word.word![Language.appLanguageCode]!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 0.12,
                  letterSpacing: 0.50,
                ),
              ),
              const SizedBox(
                width: 100,
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  '${L10n.getLanguageName(context, appLanguageCode)}:',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.12,
                    letterSpacing: 0.50,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 60,
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Text(
              word.sentence![Language.languageCodeToLearn]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                // height: 0.12,
                letterSpacing: 0.50,
              ),
              // softWrap: true, // This allows the text to wrap to the next line.
              maxLines: 3, // Set the maximum number of lines before it wraps.
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Text(
              word.sentence![Language.appLanguageCode]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                // height: 0.12,
                letterSpacing: 0.50,
              ),
              softWrap: true, // This allows the text to wrap to the next line.
              maxLines: 3, // Set the maximum number of lines before it wraps.
            ),
          ),
        ],
      ),
    );
  }
}
