import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixabay_picker/model/pixabay_media.dart';
import 'package:pixabay_picker/pixabay_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/pages/app_drawer.dart';
import 'package:words/pages/main_screen.dart';
import 'package:words/pages/user_language_picker.dart';
import 'package:words/utills/my_ad.dart';
import 'package:words/utills/word_card.dart';
import 'package:words/models/word/word.dart';
import 'package:words/pages/custom_search_bar.dart';
import 'package:words/pages/add_word.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

    static _MyHomePageState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyHomePageState>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Word> _words = [];
  bool _isLouding = false;
  // var user;
  String languageCodeToLearn = '';
  var isFavorite = true;
  var imageUrl = '';
  var isDrawerOpen = false;

  late BannerAd bannerAd;
  bool isAdLoaded = false;

  initBannerAd() {
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );
    bannerAd.load();
  }

  void _refreshWords(String lang, {String query = ''}) async {
    final data = await SQLHelper.getWordsBySearch(lang, query);
    setState(() {
      _words = data;
      isFavorite = true;
      // _isLouding = false;
    });
  }

  void refreshWordsCallback(String lang, {String term = ''}) {
    _refreshWords(lang, query: term);
  }

  Future<void> _refreshFavoritesWords() async {
    var data = await SQLHelper.getFavoritesWords(languageCodeToLearn);

    setState(() {
      _words = data;
      // _isLouding = false;
      isFavorite = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setUserLanguageToLearn();
    initBannerAd();
  }

  void setUserLanguageToLearn() {
    getUserLanguageToLearn().then((value) {
      setState(() {
        languageCodeToLearn = value;
        _refreshWords(languageCodeToLearn);
      });
    });
  }

  void handleIsLoading(bool isLoading) {
    setState(() {
      _isLouding = isLoading;
    });
  }

  Future<String> getUserLanguageToLearn() async {
    final String? languageCodeToLearn =
        await SharedPreferences.getInstance().then((prefs) {
      return prefs.getString('userLanguageToLearn');
    });
    return languageCodeToLearn!;
  }

  Future<String> manageDownloadImage(String engWord, bool isEdit,
      {String imageSearch = ''}) async {
    var documentDirectory = await getApplicationDocumentsDirectory();
    String wordSearch = imageSearch == '' ? engWord : imageSearch!;
    var filePathAndName = '${documentDirectory.path}/images/$engWord.jpg';
    //check if the directory exists
    var exists = await File(filePathAndName).exists();
    if (isEdit || !exists) {
      final img = await getImageByDom(wordSearch, isEdit);
      await downloadImage(img, engWord, filePathAndName);
    } else {
      handleIsLoading(false);
    }
    setState(() {
      imageUrl = '';
    });

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

    bool isTakeFirstImage = false;
    String limit = '';
    //isTakeFirstImage from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      isTakeFirstImage = prefs.getBool('isTakeFirstImage') ?? false;
    });
    if (isTakeFirstImage) {
      limit = '&per_page=3';
    }

    PixabayResponse? pixabayResponse = await pixabayPicker.api!
        .requestImagesWithKeyword(
            keyword: word, category: "&orientation=horizontal$limit");
    handleIsLoading(false);
    // ignore: use_build_context_synchronously
    if (!isTakeFirstImage || isEdit) {
      await selectImage(pixabayResponse!);
    }
    else{
      setState(() {
        imageUrl =
        pixabayResponse!.hits![0].getDownloadLink(res: Resolution.medium)!;
      });
    }

    if (imageUrl == '' && !isEdit) {
      print('imageUrl: $imageUrl');
      setState(() {
        imageUrl =
            pixabayResponse!.hits![0].getDownloadLink(res: Resolution.medium)!;
      });
    }
    print('imageUrl: $imageUrl');
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
            Text(
              AppLocalizations.of(context)!.selectImage,
              style: Theme.of(context).textTheme.headlineMedium,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
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
                          // color: Colors.black,
                          width: 1,
                        ),
                        // color: Colors.grey[200],
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
      endDrawer: AppDrawer(
        refreshWordsCallback: refreshWordsCallback,
        setUserLanguageToLearn: setUserLanguageToLearn,
      ),
      body: Stack(children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              // The user started scrolling, unfocus any text fields to dismiss the keyboard.
              FocusScope.of(context).unfocus();
            }
            return false; // Return false to allow other listeners to process the notification.
          },
          child: Container(
            color: Theme.of(context).canvasColor,
            child: CustomScrollView(
              slivers: [
                appBar(context),
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: true,
                  pinned: true,
                  expandedHeight: 100,
                  backgroundColor: Theme.of(context).primaryColor,
                  actions: [Container()],
                  // backgroundColor: Color.fromARGB(255, 196, 234, 244),
                  flexibleSpace: AddWord(
                    languageCodeToLearn: languageCodeToLearn,
                    refreshWordsCallback: refreshWordsCallback,
                    handleIsLoading: handleIsLoading,
                    manageDownloadImage: manageDownloadImage,
                  ),
                ),
                // SliverToBoxAdapter(
                //   child: Divider(),
                // ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // print('isFavoriteWord: ${_words[index].isFavorite}');

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
              ],
            ),
          ),
        ),
        if (_isLouding)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ]),
      bottomNavigationBar: isAdLoaded
          ? SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              child: AdWidget(
                ad: bannerAd,
              ),
            )
          : SizedBox(),
    );
  }

  SliverAppBar appBar(BuildContext context) {
    var appBarIcons = Row(
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
      ],
    );
    return SliverAppBar(
      centerTitle: true,
      pinned: true,
      expandedHeight: 100,
      backgroundColor: Theme.of(context).primaryColor,
      // leading:
      actions: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: appBarIcons,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Words',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        );
                      },
                    ),
                    // UserLanguagePickerWidget(
                    //   isUserLanguagePicker: true,
                    //   refreshWordsCallback: refreshWordsCallback,
                    //   setUserLanguageToLearn: setUserLanguageToLearn,
                    //   isAddLanguageToLearn: false,
                    //   isAppLang: false,
                    // ),
                  ),
                ),
              ],
            ),
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
    );
  }
}
