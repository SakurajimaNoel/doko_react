import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/data/storage.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageCategory extends Mock implements StorageCategory {}

class MockStorageGetUrlOperation extends Mock
    implements
        StorageGetUrlOperation<StorageGetUrlRequest, StorageGetUrlResult> {}

class FakeStorageGetUrlOptions extends Fake implements StorageGetUrlOptions {}

void main() {
  late MockStorageCategory storageCategory;
  late MockStorageGetUrlOperation storageGetUrlOperation;
  late StorageActions storageActions;

  String path = "path";
  Uri url = Uri.parse("https://www.dokii.com");

  setUp(() {
    storageCategory = MockStorageCategory();
    storageActions = StorageActions(storage: storageCategory);
    storageGetUrlOperation = MockStorageGetUrlOperation();

    registerFallbackValue(FakeStorageGetUrlOptions());
  });

  group("storage test - ", () {
    group("get download url method ", () {
      test("given path to aws s3 return download url", () async {
        when(
          () => storageCategory.getUrl(
            path: StoragePath.fromString(path),
            options: any(named: "options"),
          ),
        ).thenReturn(storageGetUrlOperation);

        when(
          () => storageGetUrlOperation.result,
        ).thenAnswer((_) async {
          return StorageGetUrlResult(url: url);
        });

        final result = await storageActions.getDownloadUrl(path);

        expect(result.status, ResponseStatus.success);
      });
    });
  });
}
