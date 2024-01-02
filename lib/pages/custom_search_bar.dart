import 'package:flutter/material.dart';
import 'package:words/pages/search/searchbar_input_decoration.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    required this.refreshWordsCallback,
    required this.labelText,
    required this.languageCodeToLearn,
    Key? key,
  }) : super(key: key);

  final Function(String lang, {String term}) refreshWordsCallback;
  final String labelText;
  final String languageCodeToLearn;
  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  var decoration;


  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void handleClose() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    widget.refreshWordsCallback(
      widget.languageCodeToLearn,
    );
  }

  void handleSearch() {
    _searchFocusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    decoration = CustomInputDecoration(
      handleClose: handleClose,
      handleSearch: handleSearch,
      labelText: widget.labelText,
      isPressed: false,
    ).getDecoration();
    _searchFocusNode.addListener(
      () {
        if (_searchFocusNode.hasFocus) {
          setState(() {

            decoration = CustomInputDecoration(
              handleClose: handleClose,
              handleSearch: handleSearch,
              labelText: widget.labelText,
              isPressed: true,
            ).getDecoration();
          });
        } else {
          setState(() {
            decoration = CustomInputDecoration(
              handleClose: handleClose,
              handleSearch: handleSearch,
              labelText: widget.labelText,
              isPressed: false,
            ).getDecoration();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: decoration,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (value) {
            widget.refreshWordsCallback(widget.languageCodeToLearn, term: value);
          },
          style: const TextStyle(
            height: 1.4,
          )
        ),
      ),
    );
  }
}
