import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:words/db/sql_helper.dart';
import 'package:words/l10n.dart';
import 'package:words/models/enums.dart';
import 'package:words/models/word/word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditWord extends StatefulWidget {
  EditWord({
    Key? key,
    required this.languageCodeToLearn,
    required this.appLanguageCode,
    required this.word,
    required this.id,
    required this.callback,
    required this.manageDownloadImage,
  }) : super(key: key);

  final String languageCodeToLearn;
  final String appLanguageCode;
  final Word word;
  final int? id;
  final Function callback;
  final Future<String> Function(String, bool) manageDownloadImage;

  @override
  _EditWordState createState() => _EditWordState();
}

class _EditWordState extends State<EditWord> {
  final _firstWordController = TextEditingController();
  final _secondWordController = TextEditingController();
  final _firstSentenceController = TextEditingController();
  final _secondSentenceController = TextEditingController();
  final _imageController = TextEditingController();
  Image? _image;
  String wordLanguageToLearnSentence = '';
  String wordAppLanguageSentence = '';
  bool isLanguageToLearnRTL = false;
  bool isAppLanguageRTL = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _firstWordController.text =
          widget.word.word![Language.languageCodeToLearn]!;
      _secondWordController.text = widget.word.word![Language.appLanguageCode]!;
      _firstSentenceController.text =
          widget.word.sentence![Language.languageCodeToLearn]!;
      _secondSentenceController.text =
          widget.word.sentence![Language.appLanguageCode]!;
      _imageController.text = widget.word.image!;
      _image = Image.file(File(widget.word.image!));
      wordLanguageToLearnSentence =
          widget.word.sentence![Language.languageCodeToLearn]!;
      wordAppLanguageSentence = widget.word.sentence![Language.appLanguageCode]!;
      isLanguageToLearnRTL =
          intl.Bidi.detectRtlDirectionality(wordLanguageToLearnSentence);
      isAppLanguageRTL =
          intl.Bidi.detectRtlDirectionality(wordAppLanguageSentence);
    }
  }

  @override
  void dispose() {
    _firstWordController.dispose();
    _secondWordController.dispose();
    _firstSentenceController.dispose();
    _secondSentenceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _updateWord(int id, Word word) async {
    final updatedWord = Word(
      language: widget.languageCodeToLearn,
      word: <Language, String>{
        Language.english: word.word![Language.english]!,
        Language.appLanguageCode: _secondWordController.text,
        Language.languageCodeToLearn: _firstWordController.text,
      },
      sentence: <Language, String>{
        Language.english: word.sentence![Language.english]!,
        Language.appLanguageCode: _secondSentenceController.text,
        Language.languageCodeToLearn: _firstSentenceController.text,
      },
      image: _imageController.text,
    );
    print('id: $id');
    await SQLHelper.updateWord(id, updatedWord);
    widget.callback(widget.languageCodeToLearn);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
        left: 15,
        right: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 120,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              await widget.manageDownloadImage(
                  widget.word.word![Language.english]!, true);
              var file = await File(widget.word.image!).readAsBytes();
              setState(() {
                imageCache.clear();
                _image = Image.memory(file);
              });
            },
            child: Center(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: _image!.image,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Image.asset(
                    'lib/assets/images/image-editing.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _firstWordController,
            decoration: InputDecoration(
              labelText:
                  L10n.getLanguageName(context, widget.languageCodeToLearn),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _secondWordController,
            decoration: InputDecoration(
              labelText: L10n.getLanguageName(context, widget.appLanguageCode),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _firstSentenceController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.sentenceInLanguage(
                  L10n.getLanguageName(context, widget.languageCodeToLearn)),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _secondSentenceController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.sentenceInLanguage(
                  L10n.getLanguageName(context, widget.appLanguageCode)),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              if (widget.id != null) {
                print('id: $widget.id');
                await _updateWord(widget.id!, widget.word);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.wordUpdated(
                          widget.word.word![Language.appLanguageCode]!),
                    ),
                  ),
                );
              }

              _firstWordController.text = '';
              _secondWordController.text = '';
              _firstSentenceController.text = '';
              _secondSentenceController.text = '';
              _imageController.text = '';
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.updateWord),
          ),
          ElevatedButton(
            onPressed: () {
              _firstWordController.text = '';
              _secondWordController.text = '';
              _firstSentenceController.text = '';
              _secondSentenceController.text = '';
              _imageController.text = '';
              widget.callback(widget.languageCodeToLearn);

              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}
