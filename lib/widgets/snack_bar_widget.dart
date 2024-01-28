import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class SnackBarWidget {
  static Future<void> showSnackBar(BuildContext context, String message,
      {Color? color}) async {
    await Flushbar(
      messageText: Text(
        message,
        textAlign: TextAlign.center,
      ),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: color ?? Theme.of(context).colorScheme.secondary,
      margin: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(10),
      duration: const Duration(seconds: 3),
    ).show(context);
  }
}
