import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:words/models/word/word.dart';
import 'package:words/models/enums.dart';
import 'package:words/models/user.dart';

//hebrew and hangul to first and second language
class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE words (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          language TEXT, 
          english TEXT, 
          first_lang TEXT, 
          second_lang TEXT, 
          sentence_english TEXT, 
          sentence_first_lang TEXT, 
          sentence_second_lang TEXT, 
          image TEXT,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )""");
    // print('createTables: words');
  

    await database.execute("""CREATE TABLE user (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          app_language TEXT,
          language_to_learn TEXT,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )""");
    // print('createTables: users');

    await database.execute("""CREATE TABLE languages (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          language TEXT,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )""");
    // print('createTables: languages');
  }

  static Future<sql.Database> db() async {
    // sql.deleteDatabase('dbwords.db');
    return sql.openDatabase(
      'dbwords.db',
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
      },
    );
  }

  static Future<int> createUser(User user) async {
    final db = await SQLHelper.db();

    final data = {
      'app_language': user.userLanguage,
      'language_to_learn': user.userLanguageToLearn,
    };

    print('createUser: $data');

    return db.insert('user', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<int> updateUser(User user) async {
    final db = await SQLHelper.db();

    final data = {
      'app_language': user.userLanguage,
      'language_to_learn': user.userLanguageToLearn,
    };

    print('updateUser: $data');

    return db.update(
      'user',
      data,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<User> getUser() async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      limit: 1,
    );

    return User(
      id: maps[0]['id'],
      userLanguage: maps[0]['app_language'],
      userLanguageToLearn: maps[0]['language_to_learn'],
    );
  }

  static Future<List<String>> getLanguages() async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'languages',
      columns: ['language'],
      groupBy: 'language',
    );

    return List.generate(maps.length, (i) {
      return maps[i]['language'] == 'iw' ? 'he' : maps[i]['language'];
    });
  }

  static Future<int> createLanguage(String lang) async {
    final db = await SQLHelper.db();

    final data = {
      'language': lang,
    };

    print('createLanguage: $data');

    return db.insert('languages', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<int> createWord(Word word) async {
    final db = await SQLHelper.db();

    final data = {
      'language': word.language ?? '',
      'english': word.word?[Language.english] ?? '',
      'first_lang': word.word?[Language.languageCodeToLearn] ?? '',
      'second_lang': word.word?[Language.appLanguageCode] ?? '',
      'sentence_english': word.sentence?[Language.english] ?? '',
      'sentence_first_lang': word.sentence?[Language.languageCodeToLearn] ?? '',
      'sentence_second_lang': word.sentence?[Language.appLanguageCode] ?? '',
      'image': word.image ?? '',
    };

    print('createWord: $data');

    return db.insert('words', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Word>> getWords(String lang) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'language = ?',
      whereArgs: [lang],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      // print('getWords: ${maps[i]}');
      final word = Word(
        id: maps[i]['id'],
        language: maps[i]['language'],
        word: <Language, String>{
          Language.english: maps[i]['english'],
          Language.languageCodeToLearn: maps[i]['first_lang'],
          Language.appLanguageCode: maps[i]['second_lang'],
        },
        sentence: <Language, String>{
          Language.english: maps[i]['sentence_english'],
          Language.languageCodeToLearn: maps[i]['sentence_first_lang'],
          Language.appLanguageCode: maps[i]['sentence_second_lang'],
        },
        image: maps[i]['image'],
      );
      // print('getWordsId: ${word.id}');
      return word;
    });
  }

  static Future<List<Word>> getWordsBySearch(String lang, String search) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'language = ? AND (first_lang LIKE ? OR second_lang LIKE ?)',
      whereArgs: [lang, '%$search%', '%$search%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      // print('getWords: ${maps[i]}');
      final word = Word(
        id: maps[i]['id'],
        language: maps[i]['language'],
        word: <Language, String>{
          Language.english: maps[i]['english'],
          Language.languageCodeToLearn: maps[i]['first_lang'],
          Language.appLanguageCode: maps[i]['second_lang'],
        },
        sentence: <Language, String>{
          Language.english: maps[i]['sentence_english'],
          Language.languageCodeToLearn: maps[i]['sentence_first_lang'],
          Language.appLanguageCode: maps[i]['sentence_second_lang'],
        },
        image: maps[i]['image'],
      );
      // print('getWordsId: ${word.id}');
      return word;
    });
  }

  static Future<Word> getWord(int id) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return Word(
      id: maps[0]['id'],
      language: maps[0]['language'],
      word: <Language, String>{
        Language.english: maps[0]['english'],
        Language.languageCodeToLearn: maps[0]['first_lang'],
        Language.appLanguageCode: maps[0]['second_lang'],
      },
      sentence: <Language, String>{
        Language.english: maps[0]['sentence_english'],
        Language.languageCodeToLearn: maps[0]['sentence_first_lang'],
        Language.appLanguageCode: maps[0]['sentence_second_lang'],
      },
      image: maps[0]['image'],
    );
  }

  static Future<int> updateWord(int id, Word word) async {
    final db = await SQLHelper.db();

    final data = {
      'language': word.language,
      'english': word.word![Language.english],
      'first_lang': word.word![Language.languageCodeToLearn],
      'second_lang': word.word![Language.appLanguageCode],
      'sentence_english': word.sentence![Language.english],
      'sentence_first_lang': word.sentence![Language.languageCodeToLearn],
      'sentence_second_lang': word.sentence![Language.appLanguageCode],
      'image': word.image,
    };

    final res = await db.update(
      'words',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );

    // print('updateWord: $res');

    return res;
  }

  static Future<void> deleteWord(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete(
        'words',
        where: 'id = ?',
        whereArgs: [id],
      );
      // print('deleteWord: $id');
    } catch (e) {
      debugPrint('ErrorDelete: $e');
    }
  }
}
