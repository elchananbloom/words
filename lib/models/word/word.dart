import '../enums.dart';

class Word {
  int? id;
  String? language;
  Map<Language, String>? word;
  Map<Language, String>? sentence;
  String? image;
  bool isFavorite;
  DateTime createDate = DateTime.now();

  Word({
    this.id,
    this.language,
    this.word,
    this.sentence,
    this.image,
    this.isFavorite = false,
  });

  static Word fromJson(word) {
    return Word(
      id: word['id'],
      language: word['language'],
      word: <Language, String>{
        Language.english: word['word'][Language.english.toString()],
        Language.languageCodeToLearn: word['word'][Language.languageCodeToLearn.toString()],
        Language.appLanguageCode: word['word'][Language.appLanguageCode.toString()],
      },
      sentence: <Language, String>{
        Language.english: word['sentence'][Language.english.toString()],
        Language.languageCodeToLearn: word['sentence'][Language.languageCodeToLearn.toString()],
        Language.appLanguageCode: word['sentence'][Language.appLanguageCode.toString()],
      },
      image: word['image'],
      isFavorite: word['isFavorite'] == 1 ? true : false,
    );
  }

  toJson() {
    var en = Language.english.toString();
    var lan = Language.languageCodeToLearn.toString();
    var app = Language.appLanguageCode.toString();
    return {
      'id': id,
      'language': language,
      'word':{
        en: word![Language.english],
        lan: word![Language.languageCodeToLearn],
        app: word![Language.appLanguageCode],
      },
      'sentence': {
        en: sentence![Language.english],
        lan: sentence![Language.languageCodeToLearn],
        app: sentence![Language.appLanguageCode],
      },
      'image': image,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}
