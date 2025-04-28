import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ChatPlaceholder extends StatelessWidget {
  const ChatPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 7,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;

          return Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe)
                    const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                  if (!isMe) const SizedBox(width: 12),
                  Container(
                    height: 0.11.sh,
                    width: 0.4.sw,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                        bottomLeft: isMe ? Radius.circular(12.r) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : Radius.circular(12.r),
                      ),
                    ),
                  ),
                  if (isMe) const SizedBox(width: 12),
                  if (isMe)
                    const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                ],
              ),
               SizedBox(height: 0.05.sh),
            ],
          );
        },
      ),
    );
  }
}
