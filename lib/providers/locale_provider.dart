import 'package:flutter/material.dart';
import 'package:words/db/sql_helper.dart';
import 'package:words/l10n.dart';
import 'package:words/models/user.dart';
import 'package:words/models/word/word.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if(!L10n.allLanguages.contains(locale)){
      return;
    }
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}

// class UserProvider extends ChangeNotifier{
//   User _user = User();

//   User get user => _user;

//   Future<void> setUser(User user) async{
//     final u  = await SQLHelper.getUser();
//     _user = u; 
//     notifyListeners();
//   }

//   void clearUser() {
//     _user = User();
//     notifyListeners();
//   }
// }

// class NewWordProvider extends ChangeNotifier{
//   String newLearnWord = '';
//   String newAppWord = '';
//   String newEnglishWord = '';
//   Word newWord = Word();

//   void setNewLearnWord(String word) {
//     newLearnWord = word;
//     notifyListeners();
//   }

//   void setNewAppWord(String word) {
//     newAppWord = word;
//     notifyListeners();
//   }

//   void setNewEnglishWord(String word) {
//     newEnglishWord = word;
//     notifyListeners();
//   }

//   void setNewWord(Word word) {
//     newWord = word;
//     notifyListeners();
//   }

//   void clearNewWord() {
//     newLearnWord = '';
//     newAppWord = '';
//     newEnglishWord = '';
//     newWord = Word();
//     notifyListeners();
//   }
// }

// class LanguageToLearn extends ChangeNotifier{
//   String _languageToLearn = '';

//   String get languageToLearn => _languageToLearn;

//   void setLanguageToLearn(String language) {
//     _languageToLearn = language;
//     notifyListeners();
//   }

//   void clearLanguageToLearn() {
//     _languageToLearn = '';
//     notifyListeners();
//   }
// }

// class AppLanguage extends ChangeNotifier{
//   String _appLanguage = '';

//   String get appLanguage => _appLanguage;

//   void setAppLanguage(String language) {
//     _appLanguage = language;
//     notifyListeners();
//   }

//   void clearAppLanguage() {
//     _appLanguage = '';
//     notifyListeners();
//   }
// }
