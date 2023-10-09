import '../enums.dart';

class Word{
  int? id;
  String? language;
  Map<Language, String>? word;
  Map<Language, String>? sentence;
  String? image;
  DateTime createDate = DateTime.now();

  Word({this.id,this.language, this.word, this.sentence, this.image});

}

