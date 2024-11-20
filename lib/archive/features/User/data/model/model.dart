import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/archive/core/data/storage.dart';
import 'package:doko_react/archive/core/helpers/display.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';

class NodeInfo {
  String? endCursor;
  bool hasNextPage;

  NodeInfo({
    required this.endCursor,
    required this.hasNextPage,
  });

  void updateInfo(String? endCursor, bool hasNextPage) {
    this.endCursor = endCursor;
    this.hasNextPage = hasNextPage;
  }

  static NodeInfo createModel({required Map map}) {
    return NodeInfo(
      endCursor: map["endCursor"],
      hasNextPage: map["hasNextPage"],
    );
  }
}

class StorageUtils {
  static final StorageActions storage =
      StorageActions(storage: Amplify.Storage);

  static Future<List<String>> generatePreSignedURLs(
      List<String> content) async {
    List<String> signedContent = List.filled(content.length, "");
    for (int i = 0; i < content.length; i++) {
      String path = content[i];
      var result = await storage.getDownloadUrl(path);
      if (result.status == ResponseStatus.success) {
        signedContent[i] = result.value;
      }
    }
    return signedContent;
  }

  static Future<String> generatePreSignedURL(String path) async {
    if (path.isEmpty) return "";

    // if already url
    if (DisplayText.isValidUrl(path)) return path;

    var result = await storage.getDownloadUrl(path);
    return result.value;
  }
}
