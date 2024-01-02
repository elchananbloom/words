import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/models/word/word.dart';
import 'package:words/models/enums.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/pages/edit_word.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/providers/speed_provider.dart';
import 'package:words/utills/snack_bar.dart';
import 'package:words/utills/speak.dart';
import 'package:words/utills/text_to_speech.dart';

class WordScreen extends ConsumerStatefulWidget {
  const WordScreen({
    Key? key,
    required this.word,
    required this.refreshWordsCallback,
    required this.manageDownloadImage,
  }) : super(key: key);

  final Word word;
  final Function(String, {String term}) refreshWordsCallback;
  final Future<String> Function(String, bool, {String imageSearch})
      manageDownloadImage;

  @override
  ConsumerState<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends ConsumerState<WordScreen> {
  late Word word;
  late Function callback;
  String? userLanguageToLearn;
  double imgHeight = 240;

  @override
  void initState() {
    super.initState();
    word = widget.word;
    callback = widget.refreshWordsCallback;
    getUserLanguageToLearn().then((value) {
      setState(() {
        userLanguageToLearn = value;
      });
    });
    getImgHeight().then((value) {
      setState(() {
        imgHeight = value;
      });
    });
  }

  Future<double> getImgHeight() async {
      File imageFile = File(word.image!);
       Uint8List imageBytes = imageFile.readAsBytesSync();

    Image image = Image.memory(
      imageBytes,
      fit: BoxFit.fitWidth,
    );

    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    ui.Image imageUI = await completer.future;
    double aspectRatio = imageUI.width / imageUI.height;
    double screenWidth = MediaQuery.of(context).size.width;
    int fittedHeight = (screenWidth / aspectRatio).round();
  
    return fittedHeight.toDouble();
      // Uint8List imageBytes = imageFile.readAsBytesSync();
      // ui.Image image = await decodeImageFromList(imageBytes);
      // return image.height.toDouble();
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
    final languageCodeToLearn = userLanguageToLearn!;
    final appLanguageCode = AppLocalizations.of(context)!.languageCode;

    Future<void> deleteWord(int id, String imgUrl, Word word) async {
      // Your existing deleteWord function logic
      await SQLHelper.deleteWord(id, imgUrl);
      widget.refreshWordsCallback(languageCodeToLearn);
      Navigator.of(context).pop();
      await SnackBarWidget.showSnackBar(
        context,
        AppLocalizations.of(context)!
            .wordDeleted(word.word![Language.appLanguageCode]!),
      );
    }

    Future<void> deleteWordConfirmation(
        BuildContext context, int id, String imgUrl, Word word) async {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteWordConfirmation(
            word: word,
          );
        },
      );

      if (confirmDelete) {
        await deleteWord(id, imgUrl, word);
      }
    }

    void editWordBottomSheet(int? id) async {
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

    final imgWidget = Image.memory(
      File(word.image!).readAsBytesSync(),
    );

    

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
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        color: Theme.of(context).colorScheme.background,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: imgHeight > 300? 300 : imgHeight,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25,
              ),
              image: DecorationImage(
                image: imgWidget.image,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          ////////////////////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  height: 290,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Table(
                          // defaultColumnWidth: FractionColumnWidth(0.33),
                          columnWidths: const {
                            0: FlexColumnWidth(0.15),
                            1: FlexColumnWidth(0.10),
                            2: FlexColumnWidth(0.50),
                            3: FlexColumnWidth(0.25),
                          },
                          // border: TableBorder.all(
                          //   color: Theme.of(context).colorScheme.secondary,
                          //   width: 1,
                          // ),
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Speak(
                                    text: word
                                        .word![Language.languageCodeToLearn]!,
                                    language: languageCodeToLearn,
                                  ),
                                ),
                                TableCell(
                                  child: SizedBox(),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Center(
                                    child: Text(
                                      word.word![Language.languageCodeToLearn]!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(
                                  child: Speak(
                                    text: word.word![Language.appLanguageCode]!,
                                    language: appLanguageCode,
                                  ),
                                ),
                                TableCell(
                                  child: SizedBox(),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Center(
                                    child: Text(
                                      word.word![Language.appLanguageCode]!,
                                      style:
                                          Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                          ],
                        ),

                        ////////////////////////////////////////////////
                        const SizedBox(
                          height: 60,
                        ),

                        Table(
                          // defaultColumnWidth: FractionColumnWidth(0.33),
                          columnWidths: const {
                            0: FlexColumnWidth(0.15),
                            1: FlexColumnWidth(0.85),
                          },
                          // border: TableBorder.all(
                          //   color: Theme.of(context).colorScheme.secondary,
                          //   width: 1,
                          // ),
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    child: Speak(
                                      text: word.sentence![
                                          Language.languageCodeToLearn]!,
                                      language: languageCodeToLearn,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8, // Adjust width as needed
                                      child: Directionality(
                                        textDirection: isLanguageToLearnRTL
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: Text(
                                          wordLanguageToLearnSentence,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    child: Speak(
                                      text: word
                                          .sentence![Language.appLanguageCode]!,
                                      language: appLanguageCode,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.8, // Adjust width as needed
                                    child: Directionality(
                                      textDirection: isAppLanguageRTL
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      child: Text(
                                        wordAppLanguageSentence,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontSize: 24,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              // height: 0.12,
                                              letterSpacing: 0.50,
                                              // color: Colors.black,
                                            ),
                                        softWrap:
                                            true, // This allows the text to wrap to the next line.
                                        maxLines:
                                            5, // Set the maximum number of lines before it wraps.
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Stack(
                        //   alignment: Alignment.center,
                        //   children: [
                        //     Align(
                        //       alignment: isLanguageToLearnRTL
                        //           ? Alignment.centerLeft
                        //           : Alignment.centerRight,
                        //       child: Speak(
                        //         text: word.sentence![Language.languageCodeToLearn]!,
                        //         language: languageCodeToLearn,
                        //       ),
                        //     ),
                        //     // SizedBox(
                        //     //   width: 100,
                        //     // ),
                        //     Padding(
                        //       padding: const EdgeInsets.only(left: 30, right: 30),
                        //       child: Align(
                        //         alignment: Alignment.center,
                        //         child: SizedBox(
                        //           width: MediaQuery.of(context).size.width *
                        //               0.8, // Adjust width as needed
                        //           child: Directionality(
                        //             textDirection: isLanguageToLearnRTL
                        //                 ? TextDirection.rtl
                        //                 : TextDirection.ltr,
                        //             child: Text(
                        //               wordLanguageToLearnSentence,
                        //               textAlign: TextAlign.center,
                        //               style: Theme.of(context).textTheme.headlineMedium,
                        //               maxLines: 3,
                        //               overflow: TextOverflow.ellipsis,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // Container(
                        //   padding: const EdgeInsets.only(left: 30, right: 30),
                        //   child: Directionality(
                        //     textDirection: isAppLanguageRTL
                        //         ? TextDirection.rtl
                        //         : TextDirection.ltr,
                        //     child: Text(
                        //       wordAppLanguageSentence,
                        //       textAlign: TextAlign.center,
                        //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        //             fontSize: 24,
                        //             fontFamily: 'Roboto',
                        //             fontWeight: FontWeight.w400,
                        //             // height: 0.12,
                        //             letterSpacing: 0.50,
                        //             // color: Colors.black,
                        //           ),
                        //       softWrap:
                        //           true, // This allows the text to wrap to the next line.
                        //       maxLines:
                        //           3, // Set the maximum number of lines before it wraps.
                        //     ),
                        //   ),
                        // ),
                      ],
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
                        onPressed: () => editWordBottomSheet(word.id),
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

  void speak(String text, String languageCodeToLearn) {
    TextToSpeech.speak(
      text,
      languageCodeToLearn,
      ref.read(speedProvider.notifier).state,
    );
  }
}

class DeleteWordConfirmation extends StatelessWidget {
  const DeleteWordConfirmation({
    required this.word,
    super.key,
  });

  final Word word;

  @override
  Widget build(BuildContext context) {
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
            Navigator.of(context).pop(true); // Return true on confirmation
          },
          child: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    );
  }
}
