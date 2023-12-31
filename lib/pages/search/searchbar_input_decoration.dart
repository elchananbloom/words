import 'package:flutter/material.dart';

class CustomInputDecoration extends InputDecoration {
  // final FocusNode focusNode;
  final bool isPressed;
  final Function() handleClose;
  final String labelText;

  CustomInputDecoration({
    Key? key,
    required this.handleClose,
    required Function() handleSearch,
    required this.labelText,
    required this.isPressed,
  }) : super(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          labelText: labelText,
          prefixIcon: IconButton(
            onPressed: handleSearch,
            icon: const Icon(
              Icons.search,
              size: 20,
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        );

  InputDecoration getDecoration() {
    if (isPressed) {
      return copyWith(
        suffixIcon: IconButton(
          onPressed: handleClose,
          icon: const Icon(
            Icons.clear,
            size: 20,
          ),
        ),
      );
    } else {
      return copyWith();
    }
  }
}
