import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixabay_picker/model/pixabay_media.dart';
import 'package:pixabay_picker/pixabay_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/pages/user_language_picker.dart';
import 'package:words/utills/word_card.dart';
import 'package:words/models/word/word.dart';
import 'package:words/pages/custom_search_bar.dart';
import 'package:words/pages/add_word.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  List<Word> _words = [];
  bool _isLouding = true;
  // var user;
  String languageCodeToLearn = '';
  var isFavorite = true;
  var imageUrl = '';

  void _refreshWords(String lang, {String query = ''}) async {
    final data = await SQLHelper.getWordsBySearch(lang, query);
    setState(() {
      _words = data;
      _isLouding = false;
    });
  }

  void refreshWordsCallback(String lang, {String term = ''}) {
    _refreshWords(lang, query: term);
  }

  Future<void> _refreshFavoritesWords() async {
    var data = await SQLHelper.getFavoritesWords(languageCodeToLearn);

    setState(() {
      _words = data;
      _isLouding = false;
      isFavorite = false;
    });
  }
  

  @override
  void initState() {
    super.initState();
    setUserLanguageToLearn();
  }

  void setUserLanguageToLearn() {
    getUserLanguageToLearn().then((value) {
      setState(() {
        languageCodeToLearn = value;
        _refreshWords(languageCodeToLearn);
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

  Future<String> manageDownloadImage(String engWord, bool isEdit) async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    var filePathAndName = '${documentDirectory.path}/images/$engWord.jpg';
    //check if the directory exists
    var exists = await File(filePathAndName).exists();
    if (isEdit || !exists) {
      final img = await getImageByDom(engWord, isEdit);
      await downloadImage(img, engWord, filePathAndName);
    }

    return filePathAndName;
  }

  Future<void> downloadImage(String? img, engWord, filePathAndName) async {
    imageCache.clear();
    var documentDirectory = await getApplicationDocumentsDirectory();
    var response = await http.get(Uri.parse(img!));
    var firstPath = '${documentDirectory.path}/images';
    await Directory(firstPath).create(recursive: true);
    File file = File(filePathAndName);

    file.writeAsBytes(response.bodyBytes);
  }

  Future<String?> getImageByDom(String word, bool isEdit) async {
    const String pixabayApiKey = '34130374-73ffceb0bd605f2db84f704e5';

    PixabayPicker pixabayPicker = PixabayPicker(apiKey: pixabayApiKey);

    PixabayResponse? pixabayResponse = await pixabayPicker.api!
        .requestImagesWithKeyword(
            keyword: word, category: "&orientation=horizontal");

    // ignore: use_build_context_synchronously
    await selectImage(pixabayResponse!);

    if (imageUrl == '' && !isEdit) {
      setState(() {
        imageUrl =
            pixabayResponse.hits![0].getDownloadLink(res: Resolution.medium)!;
      });
    }
    return imageUrl;
  }

  Future<dynamic> selectImage(PixabayResponse pixabayResponse) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return selectImageWidget(pixabayResponse);
        });
  }

  AlertDialog selectImageWidget(PixabayResponse pixabayResponse) {
    return AlertDialog(
      content: SizedBox(
        height: 500,
        width: 300,
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.selectImage),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: pixabayResponse.hits!.length,
                itemBuilder: (context, index) {
                  var imgUrl = pixabayResponse.hits![index].getDownloadLink()!;
                  var img = Image.network(imgUrl,
                      filterQuality: FilterQuality.high, fit: BoxFit.fitWidth);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        imageUrl = imgUrl;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: img.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLanguageCode = AppLocalizations.of(context)!.languageCode;
    print('appLanguageCode: $appLanguageCode');

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            // The user started scrolling, unfocus any text fields to dismiss the keyboard.
            FocusScope.of(context).unfocus();
          }
          return false; // Return false to allow other listeners to process the notification.
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              centerTitle: true,
              pinned: true,
              expandedHeight: 100,
              backgroundColor: Color.fromARGB(255, 196, 234, 244),
              actions: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.star,
                          color: !isFavorite ? Colors.yellow : Colors.grey[400],
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            print('isFavoritePage: $isFavorite');
                            await _refreshFavoritesWords();
                          } else {
                            setState(() {
                              isFavorite = true;
                            });
                            _refreshWords(languageCodeToLearn);
                          }
                        },
                      ),
                      const Text(
                        'Words',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      UserLanguagePickerWidget(
                        isChangeLang: true,
                        func: refreshWordsCallback,
                        setUserLanguageToLearn: setUserLanguageToLearn,
                      ),
                    ],
                  ),
                ),
              ],
              bottom: Tab(
                height: 80,
                child: CustomSearchBar(
                  refreshWordsCallback: refreshWordsCallback,
                  labelText: AppLocalizations.of(context)!.search,
                  languageCodeToLearn: languageCodeToLearn,
                ),
              ),
            ),
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 100,
              backgroundColor: Color.fromARGB(255, 196, 234, 244),
              flexibleSpace: AddWord(
                languageCodeToLearn: languageCodeToLearn,
                refreshWordsCallback: refreshWordsCallback,
                manageDownloadImage: manageDownloadImage,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  print('isFavoriteWord: ${_words[index].isFavorite}');

                  return WordCard(
                    word: _words[index],
                    callback: refreshWordsCallback,
                    manageDownloadImage: manageDownloadImage,
                    starColor: _words[index].isFavorite
                        ? Colors.yellow[700]!
                        : Colors.grey[400]!,
                  );
                },
                childCount: _words.length,
              ),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: _words.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       return WordCard(
            //         word: _words[index],
            //         callback: refreshWordsCallback,
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final double expandedHeight;
//   final Function(String, {String term}) refreshWordsCallback;
//   final Function() setUserLanguageToLearn;
//   final String languageCodeToLearn;

//   CustomSliverAppBarDelegate({
//     required this.expandedHeight,
//     required this.refreshWordsCallback,
//     required this.setUserLanguageToLearn,
//     required this.languageCodeToLearn,
//   });

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         buildOpen(shrinkOffset),
//         buildClose(shrinkOffset),
//       ],
//     );
//   }

//   double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

//   double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

//   Widget buildClose(double shrinkOffset) {
//     return Opacity(
//         opacity: appear(shrinkOffset),
//         child: Column(
//           children: [
//             AppBar(
//               actions: [
//                 UserLanguagePickerWidget(
//                   isChangeLang: true,
//                   func: refreshWordsCallback,
//                   setUserLanguageToLearn: setUserLanguageToLearn,
//                 ),
//               ],
//               title: const Text(
//                 'Words',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               bottom: Tab(
//                 height: 80,
//                 child: CustomSearchBar(
//                   refreshWordsCallback: refreshWordsCallback,
//                 ),
//               ),
//             ),
//           ],
//         ));
//   }

//   Widget buildOpen(double shrinkOffset) {
//     return Opacity(
//       opacity: disappear(shrinkOffset),
//       child: Column(
//         children: [
//           AppBar(
//             actions: [
//               UserLanguagePickerWidget(
//                 isChangeLang: true,
//                 func: refreshWordsCallback,
//                 setUserLanguageToLearn: setUserLanguageToLearn,
//               ),
//             ],
//             title: const Text(
//               'Words',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             bottom: Tab(
//               height: 80,
//               child: CustomSearchBar(
//                 refreshWordsCallback: refreshWordsCallback,
//               ),
//             ),
//           ),
//           AddWord(
//             languageCodeToLearn: languageCodeToLearn,
//             refreshWordsCallback: refreshWordsCallback,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   double get maxExtent => expandedHeight;

//   @override
//   double get minExtent => 140;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
//     return true;
//   }
// }
