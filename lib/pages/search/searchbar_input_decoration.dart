import 'package:flutter/material.dart';

class CustomInputDecoration extends InputDecoration {
  // final FocusNode focusNode;
  final bool isPressed;
  final Function() handleClose;

  CustomInputDecoration({Key? key, required this.handleClose, required Function() handleSearch, required this.isPressed})
      : super(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          labelText: 'Search',
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          // suffixIcon: Icon(
          //   Icons.clear,
          //   color: Colors.grey[400],
          //   size: 20,
          // ),
          prefixIcon: IconButton(
              onPressed: handleSearch,
              icon: const Icon(
                Icons.search,
                color: Colors.black,
                size: 20,
              ),
            
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        );

        InputDecoration getDecoration(){
          if(isPressed){
            return copyWith(
              suffixIcon: IconButton(
                onPressed: handleClose,
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            );
          }
          else{
            return copyWith();
          }
        }

  
  
}
