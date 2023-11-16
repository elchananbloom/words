// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:words/l10n.dart';
// import 'package:words/providers/locale_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:words/providers/new_word.dart';

// class AddLanguagePickerWidget extends riverpod.ConsumerStatefulWidget {
//   const AddLanguagePickerWidget({
//     Key? key,
//     required this.setSelectedLanguage,
//   }) : super(key: key);

//   final Function(String) setSelectedLanguage;


//   @override
//   riverpod.ConsumerState<AddLanguagePickerWidget> createState() =>
//       _LanguagePickerWidgetState();
// }

// class _LanguagePickerWidgetState
//     extends riverpod.ConsumerState<AddLanguagePickerWidget> {
//   String? flag;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonHideUnderline(
//       child: DropdownButton<String>(
//         value: flag,
//         hint: Text('Select Language'),
//         icon: Container(width: 0),
//         onChanged: (String? value) {
//           setState(() {
//             flag = value!;
//           });
//           widget.setSelectedLanguage(L10n.getLangCodeFromFlag(value!));
//         },
//         items: L10n.allLanguages.map((valueItem) {
//           String a(String b) {
//             return b;
//           }
//           return DropdownMenuItem<String>(
//             value: a(L10n.getFlag(valueItem.languageCode)),
//             child: Text(
//               '${L10n.getFlag(valueItem.languageCode)}\t\t${L10n.getLanguageName(context, valueItem.languageCode)}',
//               style: const TextStyle(fontSize: 24),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
