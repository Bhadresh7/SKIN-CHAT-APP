// import 'package:flutter/material.dart';
// import 'package:metadata_fetch/metadata_fetch.dart';
//
// class LinkPreviewWidget extends StatelessWidget {
//   final String url;
//
//   const LinkPreviewWidget({required this.url, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Metadata?>(
//       future: MetadataFetch.extract(url),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData || snapshot.data == null) return SizedBox();
//         final meta = snapshot.data!;
//         return Card(
//           margin: const EdgeInsets.only(top: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (meta.image != null)
//                 Image.network(meta.image!,
//                     height: 180, width: double.infinity, fit: BoxFit.cover),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(meta.title ?? url,
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//               ),
//               if (meta.description != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Text(meta.description!),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
