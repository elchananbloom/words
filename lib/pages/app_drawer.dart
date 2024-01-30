import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/pages/main_screen.dart';
import 'package:words/widgets/first_image_widget.dart';
import 'package:words/widgets/social_media_widget.dart';
import 'package:words/widgets/speed_slider_widget.dart';
import 'package:words/widgets/user_language_picker_widget.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    required this.refreshWordsCallback,
    required this.setUserLanguageToLearn,
    required this.showTutorial,
    super.key,
  });

  final Function? refreshWordsCallback;
  final Function()? setUserLanguageToLearn;
  final Function()? showTutorial;

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isNightMode = false;
  int wordsCount = 0;
  String email = '';

  void getWordsCount() async {
    String? userLanguageToLearn;
    await SharedPreferences.getInstance().then((prefs) {
      userLanguageToLearn = prefs.getString('userLanguageToLearn');
    });
    wordsCount = await SQLHelper.getWordsCount(userLanguageToLearn!);
    setState(() {
      wordsCount = wordsCount;
    });
  }

  @override
  void initState() {
    super.initState();
    isNightMode =
        MainScreen.of(context)!.theme == ThemeMode.dark ? true : false;
    getWordsCount();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // var restore = ListTile(
    //             title: const Text('Restore Words'),
    //             leading: const Icon(Icons.restore),
    //             onTap: () async{
    //               //alert dialog
    //               showDialog(
    //                 context: context,
    //                 builder: (context) {
    //                   return AlertDialog(
    //                     title: const Text(
    //                       'Restore Words',
    //                       textAlign: TextAlign.center,
    //                     ),
    //                     content: TextField(
    //                       decoration: InputDecoration(
    //                         hintText: 'Enter your email',
    //                       ),
    //                       onChanged: (value) {
    //                         //set email
    //                         setState(() {
    //                           email = value;
    //                         });
    //                       },
    //                     ),
    //                     actions: [
    //                       TextButton(
    //                         onPressed: () async{
    //                           Navigator.pop(context);
    //                           //restore words
    //                           await MongoDb.getWordsFromJson(email);
    //                           await MongoDb.storeAllWords(email);
    //                           //refresh words
    //                           // widget.refreshWordsCallback!();
    //                         },
    //                         child: const Text('OK'),
    //                       ),
    //                     ],
    //                   );
    //                 },
    //               );

    //             },
    //           );
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: !isNightMode
                              ? const Icon(Icons.mode_night)
                              : const Icon(Icons.wb_sunny),
                          onPressed: () {
                            setState(() {
                              isNightMode = !isNightMode;
                              MainScreen.of(context)!.handleChangeTheme();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            //pop
                            Navigator.pop(context);
                            widget.showTutorial!();
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$wordsCount',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 8),
                        UserLanguagePickerWidget(
                          isUserLanguagePicker: true,
                          refreshWordsCallback: widget.refreshWordsCallback,
                          setUserLanguageToLearn: widget.setUserLanguageToLearn,
                          isAddLanguageToLearn: false,
                          isAppLang: false,
                          wordsCount: getWordsCount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const ListTile(),
              const ListTile(),
              //restore words
              // restore,
              const FirstImage(),

              //speed
              ListTile(
                trailing: const Icon(Icons.speed),
                leading:
                    //slider speed
                    Directionality(
                  textDirection: TextDirection.ltr,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: const SpeedSliderWidget(),
                  ),
                ),
              ),
              // const Divider(),
              //choose voice
              // ListTile(
              //   title: const Text('Choose Voice'),
              //   leading: const Icon(Icons.record_voice_over),
              // ),
              // ChooseVoice(),
              //checkbox to take first image
              // const Divider(),
              const ListTile(),
              const ListTile(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(),
                  const SocialMediaWidget(),
                  //all rights reserved
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("© Elchanan Bloom.",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.grey[400],
                                )),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

////////////////////////////////////////////
