import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static final FlutterTts flutterTts = FlutterTts();

  static Future<void> speak(String text, String languageCode, double speed) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(speed/2);
    await flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await flutterTts.stop();
  }
}