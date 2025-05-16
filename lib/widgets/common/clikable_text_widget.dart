import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableTextWidget extends StatelessWidget {
  final String? text;
  final String? url;

  const ClickableTextWidget({super.key, this.text, this.url});

  @override
  Widget build(BuildContext context) {
    final urlRegExp = RegExp(r'(https?://\S+)');

    List<TextSpan> parseText(String input) {
      final matches = urlRegExp.allMatches(input);
      if (matches.isEmpty) return [TextSpan(text: input)];

      List<TextSpan> spans = [];
      int lastIndex = 0;

      for (final match in matches) {
        final urlText = match.group(0)!;

        // Add non-url text before this match
        if (match.start > lastIndex) {
          spans.add(TextSpan(text: input.substring(lastIndex, match.start)));
        }

        // Add url as clickable
        spans.add(TextSpan(
          text: urlText,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(urlText);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ));

        lastIndex = match.end;
      }

      // Add remaining text after last match
      if (lastIndex < input.length) {
        spans.add(TextSpan(text: input.substring(lastIndex)));
      }

      return spans;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text != null && text!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: parseText(text!),
              ),
            ),
          ),
        if (url != null &&
            url!.isNotEmpty &&
            (text == null || !text!.contains(url!)))
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(url!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              url!,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }
}
