import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/models/word/word.dart';
import 'package:words/models/enums.dart';
import 'package:words/pages/edit_word.dart';
import 'package:words/pages/word_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:words/widgets/delete_confirmation_widget.dart';
import 'package:words/widgets/snack_bar_widget.dart';

class WordCardWidget extends StatefulWidget {
  WordCardWidget({
    Key? key,
    required this.word,
    required this.callback,
    required this.manageDownloadImage,
    required this.starColor,
  }) : super(key: key);

  final Word word;
  final Function(String, {String term}) callback;
  final Future<String> Function(String, bool, {String imageSearch})
      manageDownloadImage;
  Color starColor;

  @override
  _WordCardWidgetState createState() => _WordCardWidgetState();
}

class _WordCardWidgetState extends State<WordCardWidget> {
  String userLanguageToLearn = '';

  @override
  void initState() {
    super.initState();
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
    final languageCodeToLearn = userLanguageToLearn!;
    final appLanguageCode = AppLocalizations.of(context)!.languageCode;

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
          word: widget.word,
          id: id,
          callback: widget.callback,
          manageDownloadImage: widget.manageDownloadImage,
        ),
      );
    }

    Future<void> deleteWord(int id, String imgUrl, Word word) async {
      // Your existing deleteWord function logic
      await SQLHelper.deleteWord(id, imgUrl);
      widget.callback(languageCodeToLearn);
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

    var image;
    try {
      image = Image.memory(File(widget.word.image!).readAsBytesSync()).image;
    } catch (e) {
      image = null;
      print(e);
    }

    final card = Card(
      key: widget.word.id == null ? null : Key(widget.word.id.toString()),
      // color: Color(0xFF88EDE7),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        //on long press edit and delete
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            elevation: 0,
            isScrollControlled: true,
            showDragHandle: true,
            shape: const RoundedRectangleBorder(
              // <-- SEE HERE
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            builder: (BuildContext context) {
              //delete and edit
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  15,
                  0,
                  // MediaQuery.of(context).viewInsets.top,
                  15,
                  MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.blue),
                      title: Text(
                        AppLocalizations.of(context)!.edit,
                        style: const TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        // Navigator.pop(context);
                        editWordBottomSheet(widget.word.id);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        AppLocalizations.of(context)!.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        // Navigator.pop(context);
                        deleteWordConfirmation(context, widget.word.id!,
                            widget.word.image!, widget.word);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        onTap: () {
          showModalBottomSheet(
            context: context,
            elevation: 0,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              // <-- SEE HERE
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            builder: (BuildContext context) {
              return WordScreen(
                word: widget.word,
                refreshWordsCallback: widget.callback,
                manageDownloadImage: widget.manageDownloadImage,
              );
            },
          );
        },
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle, // This makes the Container a circle
            border: Border.all(
              color: Colors.red, // You can change the border color
              width: 1.0, // You can adjust the border width
            ),
          ),
          child: FittedBox(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: image ?? null,
            ),
          ),
        ),
        title: Text(
          widget.word.word![Language.languageCodeToLearn]!,
        ),
        subtitle: Text(
          widget.word.word![Language.appLanguageCode]!,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.star,
            color: widget.starColor,
          ),
          onPressed: () {
            if (!widget.word.isFavorite) {
              setState(() {
                widget.starColor = Colors.yellow[700]!;
              });
              widget.word.isFavorite = true;
              SQLHelper.updateWord(widget.word.id!, widget.word);
            } else {
              setState(() {
                widget.starColor = Colors.grey[400]!;
              });
              widget.word.isFavorite = false;
              SQLHelper.updateWord(widget.word.id!, widget.word);
            }
          },
        ),
      ),
    );
    return card;
    // return Container(
    //   // width: 351,
    //   height: 106,
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(16),
    //     color: Colors.transparent,
    //   ),
    //   child: InkWell(
    //     onTap: () {
    //       showModalBottomSheet(
    //         context: context,
    //         shape: const RoundedRectangleBorder(
    //           // <-- SEE HERE
    //           borderRadius: BorderRadius.vertical(
    //             top: Radius.circular(25.0),
    //           ),
    //         ),
    //         builder: (BuildContext context) {
    //           return WordScreen(word: word, callback: callback);
    //         },
    //       );
    //     },
    //     child: Stack(
    //       children: [
    //         Positioned(
    //           left: 10,
    //           top: 2,
    //           right: 10,
    //           bottom: 2,
    //           child: Container(
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(10),
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Colors.black.withOpacity(0.2), // Shadow color
    //                   // spreadRadius: 2, // Spread radius
    //                   blurRadius: 2, // Blur radius
    //                   offset: Offset(-2, 2), // Offset in the x and y directions
    //                 ),
    //               ],
    //               color: Color(0xFF88EDE7),
    //             ),
    //           ),
    //         ),
    //         Positioned(
    //           left: 120,
    //           top: 75,
    //           child: SizedBox(
    //             child: Text(
    //               word.word![Language.appLanguageCode]!,
    //               style: const TextStyle(
    //                 color: Colors.black,
    //                 fontSize: 24,
    //                 fontFamily: 'Roboto',
    //                 fontWeight: FontWeight.w400,
    //                 height: 0.12,
    //                 letterSpacing: 0.50,
    //               ),
    //             ),
    //           ),
    //         ),
    //         Positioned(
    //           left: 120,
    //           top: 45,
    //           child: SizedBox(
    //             child: Text(
    //               word.word![Language.languageCodeToLearn]!,
    //               style: const TextStyle(
    //                 color: Colors.black,
    //                 fontSize: 24,
    //                 fontFamily: 'Roboto',
    //                 fontWeight: FontWeight.w400,
    //                 height: 0.12,
    //                 letterSpacing: 0.50,
    //               ),
    //             ),
    //           ),
    //         ),
    //         Positioned(
    //           left: 14,
    //           top: 12,
    //           child: Container(
    //             width: 82,
    //             height: 82,
    //             decoration: ShapeDecoration(
    //               image: DecorationImage(
    //                 image: Image.network(word.image!).image,
    //                 filterQuality: FilterQuality.high,
    //                 fit: BoxFit.fill,
    //               ),
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(10),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
