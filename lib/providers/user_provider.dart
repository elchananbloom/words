import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/models/user.dart';
import 'package:words/providers/new_word.dart';



final userProvider = FutureProvider<User>((ref) async {
  ref.watch(languageCodeToLearnProvider);
  final user = await SQLHelper.getUser();
  print('allUser: ${user.userLanguage} ${user.userLanguageToLearn} $user');
  return user;
});
