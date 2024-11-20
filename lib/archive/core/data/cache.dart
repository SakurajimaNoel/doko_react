import 'dart:io';

import 'package:doko_react/archive/core/helpers/media_type.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Cache {
  static final _cacheManager = DefaultCacheManager();

  static Future<void> addFileToCache(String path, String key) async {
    String? fileExtension =
        MediaType.getExtensionFromFileName(path, withDot: false);

    if (fileExtension == null) return;

    File fileToSave = File(path);

    if (!await fileToSave.exists()) return;

    await _cacheManager.putFile(
      key,
      fileToSave.readAsBytesSync(),
      fileExtension: fileExtension,
    );
  }

  static Future<String?> getFileFromCache(String key) async {
    final cacheFile = await _cacheManager.getFileFromCache(key);

    if (cacheFile == null) return null;

    return cacheFile.file.path;
  }
}
