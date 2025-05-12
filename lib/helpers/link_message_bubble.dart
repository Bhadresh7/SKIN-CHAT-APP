import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:provider/provider.dart';
import 'package:skin_chat_app/providers/auth/my_auth_provider.dart';

class LinkMessageBubble extends StatefulWidget {
  final types.TextMessage message;
  final bool nextMessageInGroup;
  final Widget child;

  const LinkMessageBubble({
    super.key,
    required this.message,
    required this.nextMessageInGroup,
    required this.child,
  });

  @override
  State<LinkMessageBubble> createState() => _LinkMessageBubbleState();
}

class _LinkMessageBubbleState extends State<LinkMessageBubble> {
  // Extract URLs from text
  List<String> _extractUrls(String text) {
    final urlRegExp = RegExp(
      "https?://(www.)?[-a-zA-Z0-9@:%._+~#=]{1,256}.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&//=]*)",
      caseSensitive: false,
    );

    final matches = urlRegExp.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _extractUrls(widget.message.text);

    // If no URLs in the message, return the default bubble
    if (urls.isEmpty) {
      return widget.child;
    }

    // We'll use the first URL found for the preview
    final url = urls.first;
    final isCurrentUser = widget.message.author.id ==
        Provider.of<MyAuthProvider>(context, listen: false).uid;

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Original chat bubble with text
        widget.child,

        // Link preview
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: LinkPreview(
                enableAnimation: true,
                onPreviewDataFetched: (data) {
                  // You can save the preview data to your database here if needed
                },
                previewData: null,
                // Let the widget fetch data itself
                text: url,
                width: MediaQuery.of(context).size.width * 0.7,
                // openOnClick: true,
                hideImage: false,
                // backgroundColor: Colors.transparent,

                imageBuilder: (imageUrl) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.link,
                              size: 40, color: Colors.grey[500]),
                        );
                      },
                    ),
                  );
                },
                // textStyle: TextStyle(
                //   color: isCurrentUser ? Colors.white : Colors.black87,
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                // ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
