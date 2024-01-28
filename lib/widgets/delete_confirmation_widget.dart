import 'package:flutter/material.dart';
import 'package:words/models/enums.dart';
import 'package:words/models/word/word.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DeleteWordConfirmation extends StatelessWidget {
  const DeleteWordConfirmation({
    required this.word,
    super.key,
  });

  final Word word;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        AppLocalizations.of(context)!
            .confirmDelete(word.word![Language.appLanguageCode]!),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false on cancel
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Return true on confirmation
          },
          child: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    );
  }
}
