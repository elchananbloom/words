import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:words/providers/speed_provider.dart';
import 'package:words/utills/text_to_speech.dart';

class SpeakWidget extends ConsumerWidget {
  const SpeakWidget({
    Key? key,
    required this.text,
    required this.language,
  }) : super(key: key);

  final String text;
  final String language;

  @override
  Widget build(BuildContext context, ref) {
    return IconButton(
      icon: const Icon(
        Icons.volume_up,
        size: 30,
      ),
      color: Colors.blue,
      tooltip: 'Speak',
      onPressed: () {
        TextToSpeech.speak(
          text,
          language,
          ref.read(speedProvider.notifier).state,
        );
      },
    );
  }
}
