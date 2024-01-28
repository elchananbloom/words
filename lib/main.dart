import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:words/db/mongodb.dart';
import 'package:words/pages/main_screen.dart';

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // await MongoDb.connectToMongoDb();
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://c2872ea0323f19669c3ff38e2c239091@o4506532157784064.ingest.sentry.io/4506532159815680';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isUserRegistered = prefs.getBool('isUserRegistered') ?? false;
  bool isUserHalfRegistered = prefs.getBool('isUserHalfRegistered') ?? false;
  String? userLanguageToLearn = prefs.getString('userLanguageToLearn');
  String? appLanguage = prefs.getString('appLanguage');
  // bool isUserRegistered = false;
  runApp(ProviderScope(
      child: MainScreen(
    isUserRegistered: isUserRegistered,
    isUserHalfRegistered: isUserHalfRegistered,
    userLanguageToLearn: userLanguageToLearn,
    appLanguage: appLanguage,
  )));
    }
  );
  // var devices = ["53B59DB49CC81D357BE4173D4A078798"];

  // await MobileAds.instance.initialize();
  // RequestConfiguration configuration =
  //     RequestConfiguration(testDeviceIds: devices);
  // MobileAds.instance.updateRequestConfiguration(configuration);


  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isUserRegistered = prefs.getBool('isUserRegistered') ?? false;
  bool isUserHalfRegistered = prefs.getBool('isUserHalfRegistered') ?? false;
  String? userLanguageToLearn = prefs.getString('userLanguageToLearn');
  String? appLanguage = prefs.getString('appLanguage');
  // bool isUserRegistered = false;
  runApp(ProviderScope(
      child: MainScreen(
    isUserRegistered: isUserRegistered,
    isUserHalfRegistered: isUserHalfRegistered,
    userLanguageToLearn: userLanguageToLearn,
    appLanguage: appLanguage,
  )));
}
