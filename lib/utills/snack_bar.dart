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
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //       content: Center(
    //         child: Text(
    //           message,
    //           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    //             color: Colors.black,
    //           )
    //         ),
    //       ),
    //       backgroundColor: color,
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    //       margin: EdgeInsets.only(
    //         bottom: MediaQuery.of(context).size.height * 0.9,
    //         // bottom: 10,
    //         left: 10,
    //         right: 10,
    //       ),
    //     ),
    // );
  }
}
