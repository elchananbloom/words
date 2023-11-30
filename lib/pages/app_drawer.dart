import 'package:flutter/material.dart';
import 'package:words/pages/user_language_picker.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.refreshWordsCallback,
    required this.setUserLanguageToLearn,
    super.key,
  });

  final Function? refreshWordsCallback;
  final Function()? setUserLanguageToLearn;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: UserLanguagePickerWidget(
              isUserLanguagePicker: true,
              refreshWordsCallback: refreshWordsCallback,
              setUserLanguageToLearn: setUserLanguageToLearn,
              isAddLanguageToLearn: false,
              isAppLang: false,
            ),
          ),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
