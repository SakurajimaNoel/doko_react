import '../../../../core/data/storage.dart';
import '../../../../core/helpers/enum.dart';

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
  static Future<List<String>> generatePreSignedURLs(
      List<String> content) async {
    List<String> signedContent = List.filled(content.length, "");
    for (int i = 0; i < content.length; i++) {
      String path = content[i];
      var result = await StorageActions.getDownloadUrl(path);
      if (result.status == ResponseStatus.success) {
        signedContent[i] = result.value;
      }
    }
    return signedContent;
  }

  static Future<String> generatePreSignedURL(String path) async {
    var result = await StorageActions.getDownloadUrl(path);
    return result.value;
  }
}
