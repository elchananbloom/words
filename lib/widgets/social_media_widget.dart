import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaWidget extends StatelessWidget {
  const SocialMediaWidget({
    Key? key,
  }) : super(key: key);

  Future<void> launchLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Tooltip(
          message: 'LinkedIn',
          child: IconButton(
            onPressed: () async {
              const url = 'https://linkedin.com/in/elchananbloom';
              await launchLink(url);
            },
            icon: const FaIcon(FontAwesomeIcons.linkedinIn),
          ),
        ),
        Tooltip(
          message: 'GitHub',
          child: IconButton(
            onPressed: () async {
              const url = 'https://github.com/elchananbloom';
              await launchLink(url);
            },
            icon: const FaIcon(FontAwesomeIcons.github),
          ),
        ),
        Tooltip(
          message: 'Telegram',
          child: IconButton(
            onPressed: () async {
              const url = 'https://t.me/elchananbloom';
              await launchLink(url);
            },
            icon: const FaIcon(FontAwesomeIcons.telegram),
          ),
        ),
        Tooltip(
          message: 'Email',
          child: IconButton(
            onPressed: () async {
              const url = 'mailto:elchananbloom12@gmail.com';
              await launchLink(url);
            },
            icon: const FaIcon(FontAwesomeIcons.envelope),
          ),
        ),
      ],
    );
  }
}
