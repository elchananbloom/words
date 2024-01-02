import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TextToSpeech {
  static final FlutterTts flutterTts = FlutterTts();

  static Future<void> speak(String text, String languageCode, double speed) async {
    //dictionary for language code to locale
    // var languageCodeToMaleVoice = {
    //   'en': {'name': 'en-us-x-iol-local', 'locale': 'en-US'},
    //   'ko': {'name': 'ko-kr-x-koc-network', 'locale': 'ko-KR'},
    //   'ja': {'name': 'ja-jp-x-jab-network', 'locale': 'ja-JP'},
    // };
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(speed/2);
    // var voices = await flutterTts.getVoices;
    // var defaultVoice = await flutterTts.getDefaultVoice;
    // print('defaultVoice: $defaultVoice');
    //check if voice have locale that languageCode is in it
    //if not, set voice to default
    
    // for (var item in voices) {
    //   print(item);
    // }
    // var maleVoice = languageCodeToMaleVoice[languageCode]!;
    // await flutterTts.setVoice({"name": "${a.toLowerCase()}-x-iol-local", "locale": a});

    // await flutterTts.setVoice(maleVoice);
    await flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await flutterTts.stop();
  }
}