import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatPlaceholder extends StatelessWidget {
  const ChatPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
