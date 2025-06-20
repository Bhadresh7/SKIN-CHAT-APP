import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class UrlToFileHelper {
  static Future<File> urlToFileHelperConvertor({required String url}) async {
    final dio = Dio();

    final downloadDirectory = await getDownloadsDirectory();
    final filePath =
        '${downloadDirectory?.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await dio.download(
      url,
      filePath,
    );

    return File(filePath);
  }
}
