import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:words/models/word/word.dart';
import 'package:words/models/enums.dart';

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
          is_favorite INTEGER DEFAULT 0,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )""");

    await database.execute("""CREATE TABLE languages (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          language TEXT,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )""");
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

    return db.insert('languages', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<int> deleteLanguage(String lang) async {
    final db = await SQLHelper.db();

    return db.delete(
      'languages',
      where: 'language = ?',
      whereArgs: [lang],
    );
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
      'is_favorite': word.isFavorite ? 1 : 0,
    };

    // Check if a word with the same 'first_lang' and 'second_lang' exists.
    final existingWord = await db.query('words',
        where:
            'language = ? AND LOWER(first_lang) = ? AND LOWER(second_lang) = ?',
        whereArgs: [
          data['language'].toString(),
          data['first_lang'].toString().toLowerCase(),
          data['second_lang'].toString().toLowerCase()
        ]);

    if (existingWord.isEmpty) {
      // No existing word with the same 'first_lang' and 'second_lang', so insert the new word.
      return db.insert('words', data,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    } else {
      // A word with the same 'first_lang' and 'second_lang' already exists.
      // You can handle this case accordingly, e.g., return an error code or message.
      return -1; // Change this to an appropriate error code or handle it as needed.
    }
  }

  static Future<List<Word>> getFavoritesWords(String lang) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'language = ? AND is_favorite = 1',
      whereArgs: [lang],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
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
        isFavorite: maps[i]['is_favorite'] == 1 ? true : false,
      );
      return word;
    });
  }

  static Future<List<Word>> getWordsBySearch(String lang, String search) async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where:
          'language = ? AND (LOWER(first_lang) LIKE ? OR LOWER(second_lang) LIKE ?)',
      whereArgs: [
        lang,
        '%${search.toLowerCase()}%',
        '%${search.toLowerCase()}%'
      ],
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
        isFavorite: maps[i]['is_favorite'] == 1 ? true : false,
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
      isFavorite: maps[0]['is_favorite'] == 1 ? true : false,
    );
  }

  static Future<int> updateWord(int id, Word word) async {
    final db = await SQLHelper.db();
    final data = {
      'id': id,
      'language': word.language,
      'english': word.word![Language.english],
      'first_lang': word.word![Language.languageCodeToLearn],
      'second_lang': word.word![Language.appLanguageCode],
      'sentence_english': word.sentence![Language.english],
      'sentence_first_lang': word.sentence![Language.languageCodeToLearn],
      'sentence_second_lang': word.sentence![Language.appLanguageCode],
      'image': word.image,
      'is_favorite': word.isFavorite ? 1 : 0,
    };

    final res = await db.update(
      'words',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );


    return res;
  }

  static Future<void> deleteWord(int id, String imageUrl) async {
    final db = await SQLHelper.db();

    try {
      await db.delete(
        'words',
        where: 'id = ?',
        whereArgs: [id],
      );
      final existingWord =
          await db.query('words', where: 'image = ?', whereArgs: [imageUrl]);
      if (existingWord.isEmpty) {
        File file = File(imageUrl);
        await file.delete();
      }

    } catch (e) {
      debugPrint('ErrorDelete: $e');
    }
  }
}
