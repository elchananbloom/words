import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:words/db/sql_helper.dart';

final languagesProvider = FutureProvider<List<String>>((ref) async {
  final languages = await SQLHelper.getLanguages();
  return languages;
});
