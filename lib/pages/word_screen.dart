import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/models/word/word.dart';
import 'package:words/models/enums.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/pages/edit_word.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WordScreen extends ConsumerStatefulWidget {
  const WordScreen({
    Key? key,
    required this.word,
    required this.callback,
    required this.manageDownloadImage,
  }) : super(key: key);

  final Word word;
  final Function(String, {String term}) callback;
  final Future<String> Function(String, bool) manageDownloadImage;

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
    // final user = ref.read(userProvider).asData!.value;

    final languageCodeToLearn = userLanguageToLearn!;
    // ref.read(languageCodeToLearnProvider.notifier).state;
    final appLanguageCode = AppLocalizations.of(context)!.languageCode;

    // final first_lang = ref.read(firstLangProvider.notifier).state;
    // final second_lang = ref.read(secondLangProvider.notifier).state;
    Future<void> deleteWord(int id, String imgUrl, Word word) async {
      // Your existing deleteWord function logic
      await SQLHelper.deleteWord(id, imgUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .wordDeleted(word.word![Language.appLanguageCode]!),
          ),
        ),
      );
      callback(languageCodeToLearn);
      Navigator.of(context).pop();
    }

    Future<void> deleteWordConfirmation(
        BuildContext context, int id, String imgUrl, Word word) async {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              AppLocalizations.of(context)!
                  .confirmDelete(word.word![Language.appLanguageCode]!),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false on cancel
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Return true on confirmation
                },
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          );
        },
      );

      if (confirmDelete) {
        await deleteWord(id, imgUrl, word);
      }
    }

    void showForm(int? id) async {
      showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        showDragHandle: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (_) => EditWord(
          languageCodeToLearn: languageCodeToLearn,
          appLanguageCode: appLanguageCode,
          word: word,
          id: id,
          callback: callback,
          manageDownloadImage: widget.manageDownloadImage,
        ),
      );
    }

    print('word.image: ${word.image}');
    // final imgSrc = word.image!.split(',')[1];

    // print('imgSrc: $imgSrc');

    // final decodedBytes = base64Decode(imgSrc);
    // print('decodedBytes: $decodedBytes');
    // const strUri = 'https://thumbor.forbes.com/thumbor/fit-in/900x510/https://www.forbes.com/advisor/wp-content/uploads/2023/07/top-20-small-dog-breeds.jpeg.jpg';
    final imgWidget = Image.memory(File(word.image!).readAsBytesSync());
    // Create an Image widget
    // final imageWidget = Image.memory(
    //   decodedBytes,
    //   width: 200,
    //   height: 200,
    //   fit: BoxFit.cover,);

    // Color color = Colors.black;
    // List<Shadow> shadows = const <Shadow>[
    //   Shadow(
    //       // bottomLeft
    //       offset: Offset(-1.0, -1.0),
    //       color: Colors.black),
    //   Shadow(
    //       // bottomRight
    //       offset: Offset(1.0, -1.0),
    //       color: Colors.black),
    //   Shadow(
    //       // topRight
    //       offset: Offset(1.0, 1.0),
    //       color: Colors.black),
    //   Shadow(
    //       // topLeft
    //       offset: Offset(-1.0, 1.0),
    //       color: Colors.black),
    // ];
    final wordLanguageToLearnSentence =
        word.sentence![Language.languageCodeToLearn]!;
    final wordAppLanguageSentence = word.sentence![Language.appLanguageCode]!;
    final isLanguageToLearnRTL =
        intl.Bidi.detectRtlDirectionality(wordLanguageToLearnSentence);
    final isAppLanguageRTL =
        intl.Bidi.detectRtlDirectionality(wordAppLanguageSentence);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imgWidget.image,
          filterQuality: FilterQuality.high,
          fit: BoxFit.cover,
        ),
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(25),
        //     topRight: Radius.circular(25),
        //   ),
        // ),
      ),
      child: Column(
        // controller: controller,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imgWidget.image,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 30, right: 30),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              color: Theme.of(context).colorScheme.background,
              // color: Colors.white,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      word.word![Language.languageCodeToLearn]!,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Text(
                      word.word![Language.appLanguageCode]!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
                Directionality(
                  textDirection: isLanguageToLearnRTL
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Text(
                    wordLanguageToLearnSentence,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                    // softWrap: true, // This allows the text to wrap to the next line.
                    maxLines:
                        3, // Set the maximum number of lines before it wraps.
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Directionality(
                    textDirection: isAppLanguageRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Text(
                      wordAppLanguageSentence,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 24,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            // height: 0.12,
                            letterSpacing: 0.50,
                            color: Colors.black,
                          ),
                      softWrap:
                          true, // This allows the text to wrap to the next line.
                      maxLines:
                          3, // Set the maximum number of lines before it wraps.
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).splashColor,
                        // Colors.grey[200], // Use a subtle background color
                        borderRadius: BorderRadius.circular(
                            8), // Slightly rounded corners
                      ),
                      padding: EdgeInsets.all(8), // Add some padding
                      child: IconButton(
                        onPressed: () => showForm(word.id),
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue, // Choose a modern color
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).splashColor,
                        //     Colors.grey[200], // Use the same background color
                        borderRadius: BorderRadius.circular(
                            8), // Slightly rounded corners
                      ),
                      padding: EdgeInsets.all(8), // Add some padding
                      child: IconButton(
                        onPressed: () {
                          deleteWordConfirmation(
                              context, word.id!, word.image!, word);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red, // Choose a modern color
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
