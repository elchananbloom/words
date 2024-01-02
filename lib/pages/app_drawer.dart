import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/pages/main_screen.dart';
import 'package:words/pages/my_home.dart';
import 'package:words/pages/social_media.dart';
import 'package:words/pages/speed_slider.dart';
import 'package:words/pages/user_language_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({
    required this.refreshWordsCallback,
    required this.setUserLanguageToLearn,
    super.key,
  });

  final Function? refreshWordsCallback;
  final Function()? setUserLanguageToLearn;

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  var isNightMode;
  var wordsCount;

  void getWordsCount() async {
    var userLanguageToLearn;
    await SharedPreferences.getInstance().then((prefs) {
      userLanguageToLearn = prefs.getString('userLanguageToLearn');
    });
    wordsCount = await SQLHelper.getWordsCount(userLanguageToLearn);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$wordsCount',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 8),
                        // const Spacer(),
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
              //night mode
              // ListTile(
              //   title: !isNightMode
              //       ? const Text('Night Mode')
              //       : const Text('Day Mode'),
              //   leading: !isNightMode
              //       ? const Icon(Icons.nightlight_round)
              //       : const Icon(Icons.wb_sunny),
              //   // Switch(
              //   //   value: isNightMode,
              //   //   onChanged: (value) {
              //   //     isNightMode = value;
              //   //     MainScreen.of(context)!.handleChangeTheme();
              //   //   },
              //   // ),
              //   onTap: () {
              //     setState(() {
              //       isNightMode = !isNightMode;
              //       MainScreen.of(context)!.handleChangeTheme();
              //     });
              //     // isNightMode = !isNightMode;
              //     // MainScreen.of(context)!.handleChangeTheme();
              //   },
              // ),
              // const Divider(),
              const ListTile(),
              const ListTile(),
              FirstImage(),

              //speed
              ListTile(
                // title: Text('Speed'),
                trailing: Icon(Icons.speed),
                leading:
                    //slider speed
                    Directionality(
                  textDirection: TextDirection.ltr,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: SpeedSlider()),
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
              ListTile(),
              ListTile(),
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
                  const SocialMedia(),
                  //all rights reserved
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text("© Elchanan Bloom.",
                        // AppLocalizations.of(context)!.allRightsReserved,
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
class FirstImage extends StatefulWidget {
  const FirstImage({
    super.key,
  });

  @override
  _FirstImageState createState() => _FirstImageState();
}

class _FirstImageState extends State<FirstImage> {
  late bool isTakeFirstImage;

  @override
  void initState() {
    super.initState();
    //isTakeFirstImage from shared preferences
    getIsTakeFirstImage();
  }

  void getIsTakeFirstImage() async {
    await SharedPreferences.getInstance().then((prefs) {
      isTakeFirstImage = prefs.getBool('isTakeFirstImage') ?? false;
      setState(() {
        isTakeFirstImage = isTakeFirstImage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Take First Image'),
      trailing: const Icon(Icons.camera_alt),
      leading: Checkbox(
        value: isTakeFirstImage,
        onChanged: (value) {
          setState(() {
            setIsTakeFirstImage(value);
          });
        },
      ),
      onTap: () {
        //pop up dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Take First Image',
                textAlign: TextAlign.center,
              ),
              content: const Text(
                  'If you want to take the first image of the word from the internet, check this box.',
                  textAlign: TextAlign.center
                  ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          setIsTakeFirstImage(!isTakeFirstImage);
        });
      },
    );
  }

  void setIsTakeFirstImage(bool? value) {
    isTakeFirstImage = value!;
    //save isTakeFirstImage to shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isTakeFirstImage', isTakeFirstImage);
    });
  }
}

////////////////////////////////////////////////
class ChooseVoice extends StatefulWidget {
  const ChooseVoice({
    super.key,
  });

  @override
  _ChooseVoiceState createState() => _ChooseVoiceState();
}

class _ChooseVoiceState extends State<ChooseVoice> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: 'en-us-x-iol-local',
      onChanged: (value) {},
      items: [],
    );
  }
}
