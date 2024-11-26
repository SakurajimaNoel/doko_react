import 'dart:io';

import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final _cacheManager = DefaultCacheManager();

Future<void> addFileToCache(String filePath, String key) async {
  String? fileExtension = getFileExtensionFromFileName(filePath);

  if (fileExtension == null) return;

  File fileToSave = File(filePath);

  if (!await fileToSave.exists()) return;

  await _cacheManager.putFile(
    key,
    fileToSave.readAsBytesSync(),
    fileExtension: fileExtension,
  );
}

Future<String?> getFileFromCache(String key) async {
  final cacheFile = await _cacheManager.getFileFromCache(key);

  if (cacheFile == null) return null;

  return cacheFile.file.path;
}
