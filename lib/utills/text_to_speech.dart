import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TextToSpeech {
  static final FlutterTts flutterTts = FlutterTts();

  static Future<void> speak(String text, String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    // await flutterTts.setSpeechRate(0.5);
    // var a = await flutterTts.getVoices;
    // for (var item in a) {
    //   print(item);
    // }
    // await flutterTts.setVoice({"name": "en-us-x-iol-local", "locale": "en-US"});
    await flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await flutterTts.stop();
  }
}