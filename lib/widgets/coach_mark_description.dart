import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CoachMarkDescription extends StatefulWidget {
  const CoachMarkDescription({
    super.key,
    required this.description,
    this.next,
    this.onSkip,
    this.onNext,
  });

  final String description;
  final String? next;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;

  @override
  State<CoachMarkDescription> createState() => __CoachMarkDescriptionState();
}

class __CoachMarkDescriptionState extends State<CoachMarkDescription> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onSkip,
                child: Text(AppLocalizations.of(context)!.skip),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: widget.onNext,
                child: Text(widget.next?? AppLocalizations.of(context)!.next),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
