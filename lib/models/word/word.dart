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
}
