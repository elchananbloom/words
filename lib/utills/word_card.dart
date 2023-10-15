import 'package:flutter/material.dart';
import 'package:words/models/word/word.dart';
import 'package:words/models/enums.dart';
import 'package:words/pages/word_screen.dart';

class WordCard extends StatelessWidget {
  const WordCard({Key? key, required this.word, required this.callback})
      : super(key: key);

  final Word word;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      key: word.id == null ? null : Key(word.id.toString()),
      color: Color(0xFF88EDE7),
      elevation: 4,
      
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              // <-- SEE HERE
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            builder: (BuildContext context) {
              return WordScreen(word: word, callback: callback);
            },
          );
        },
        leading: FittedBox(
          child: CircleAvatar(
            radius: 40,

            backgroundImage: Image.network(word.image!).image,
          ),
        ),
        title: Text(
          word.word![Language.languageCodeToLearn]!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.50,

          ),
        ),
        subtitle: Text(
          word.word![Language.appLanguageCode]!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Roboto',

          ),
        ),
      )
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
