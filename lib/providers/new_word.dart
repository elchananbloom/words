import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:words/models/word/word.dart';

final newLangToLearnWordProvider = StateProvider<String>((ref) => '');

final newAppLangWordProvider = StateProvider<String>((ref) => '');
final newEnglishWordProvider = StateProvider<String>((ref) => '');

final firstLangProvider =StateProvider<String>((ref) => '');
final secondLangProvider =StateProvider<String>((ref) => '');

final languageCodeToLearnProvider = StateProvider<String>((ref) => '');

final newWordProvider = StateProvider<Word>((ref) => Word());