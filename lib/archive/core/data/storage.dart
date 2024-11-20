import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:aws_common/vm.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:flutter/foundation.dart';

class StorageResult {
  final ResponseStatus status;
  final String value;

  const StorageResult({
    required this.status,
    required this.value,
  });
}

class StorageActions {
  final StorageCategory storage;

  // send storage = Amplify.Storage
  StorageActions({
    required this.storage,
  });

  Future<StorageResult> getDownloadUrl(String path) async {
    try {
      final result = await storage
          .getUrl(
            path: StoragePath.fromString(path),
            options: const StorageGetUrlOptions(
              pluginOptions: S3GetUrlPluginOptions(
                expiresIn: Duration(
                  minutes: 60,
                ),
              ),
            ),
          )
          .result;
      String url = result.url.toString();

      return StorageResult(
        status: ResponseStatus.success,
        value: url,
      );
    } on StorageException catch (e) {
      return StorageResult(
        status: ResponseStatus.error,
        value: e.message,
      );
    } catch (e) {
      safePrint(e.toString());

      return const StorageResult(
        status: ResponseStatus.error,
        value: "Oops, Something went wrong!",
      );
    }
  }

  Future<StorageResult> uploadFile(File file, String path) async {
    try {
      final result = await storage
          .uploadFile(
            localFile: AWSFilePlatform.fromFile(file),
            path: StoragePath.fromString(path),
          )
          .result;
      return StorageResult(
        status: ResponseStatus.success,
        value: result.uploadedItem.path,
      );
    } on StorageException catch (e) {
      return StorageResult(
        status: ResponseStatus.error,
        value: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return const StorageResult(
        status: ResponseStatus.error,
        value: "Oops, Something went wrong!",
      );
    }
  }

  Future<StorageResult> uploadBytes(Uint8List data, String path) async {
    try {
      final result = await storage
          .uploadFile(
            localFile: AWSFile.fromData(data),
            path: StoragePath.fromString(path),
          )
          .result;
      return StorageResult(
        status: ResponseStatus.success,
        value: result.uploadedItem.path,
      );
    } on StorageException catch (e) {
      return StorageResult(
        status: ResponseStatus.error,
        value: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return const StorageResult(
        status: ResponseStatus.error,
        value: "Oops, Something went wrong!",
      );
    }
  }

  Future<StorageResult> deleteFile(String path) async {
    try {
      final result = await storage
          .remove(
            path: StoragePath.fromString(path),
          )
          .result;

      return StorageResult(
        status: ResponseStatus.success,
        value: result.removedItem.path,
      );
    } on StorageException catch (e) {
      return StorageResult(
        status: ResponseStatus.error,
        value: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return const StorageResult(
        status: ResponseStatus.error,
        value: "Oops, Something went wrong!",
      );
    }
  }
}
