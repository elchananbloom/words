import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/pages/main_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isUserRegistered = prefs.getBool('isUserRegistered') ?? false;
  String? userLanguageToLearn = prefs.getString('userLanguageToLearn');
  String? appLanguage = prefs.getString('appLanguage');
  // bool isUserRegistered = false;
  runApp(ProviderScope(
      child: MainScreen(
    isUserRegistered: isUserRegistered,
    userLanguageToLearn: userLanguageToLearn,
    appLanguage: appLanguage,
  )));
}
