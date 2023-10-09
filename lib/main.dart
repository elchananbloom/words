import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:words/pages/main_screen.dart';

Future main() async{
  runApp(const ProviderScope(child: MainScreen()));
}