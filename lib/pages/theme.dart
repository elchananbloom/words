import 'package:flutter/material.dart';

class MyThemeData {
  static final ThemeData lightTheme = ThemeData(
    //textfield border, cursor color, icon color, select user language color, word screen backgroung color
    primarySwatch: Colors.brown,
    // app bar color
    primaryColor: Colors.blue[100],
    hintColor: Colors.grey,
    //iconButton background color
    splashColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.brown,
      secondary: Colors.blue,
      background: Colors.blue[100]!,
      error: Colors.red,
    ),
    //dropdown menu color, list background color
    canvasColor: Colors.blueGrey[50],
    //add word button, next, update, cancel, continue
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.lightGreen,
      contentTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      // labelText: 'Word',
      // labelStyle: TextStyle(
      //   color: Colors.black,
      // ),
      // hintText: 'Word',
      // hintStyle: TextStyle(
      //   color: Colors.grey,
      // ),
    ),
    // word card color
    cardColor: Colors.blue,
    cardTheme: const CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    ),
    iconButtonTheme:  IconButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
      
    ),
    dialogTheme: const DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
    ),
    dialogBackgroundColor: Colors.blue[100],
    
    listTileTheme: const ListTileThemeData(
      textColor: Colors.black,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
        letterSpacing: 0.50,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
    ),
    textTheme: const TextTheme(
      //Words title style, word screen word
      headlineLarge: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
        height: 0.12,
        letterSpacing: 0.50,
        color: Colors.black,
      ),
      //word screen word
      titleLarge: TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
        height: 0.12,
        letterSpacing: 0.50,
        color: Colors.black,
      ),
      //word screen sentence
      headlineMedium: TextStyle(
        fontSize: 24,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        // height: 0.12,
        letterSpacing: 0.50,
        color: Colors.black,
      ),
      //hint text style
      titleMedium: TextStyle(
        fontSize: 14,
      ),
      // //add word style
      headlineSmall: TextStyle(
        fontSize: 16.0,
        // fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayLarge: TextStyle(
        fontSize: 72.0,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontSize: 36.0,
        fontStyle: FontStyle.italic,
      ),
      //add word style
      displaySmall: TextStyle(
        fontSize: 14.0,
      ),
    ),
  );
}
