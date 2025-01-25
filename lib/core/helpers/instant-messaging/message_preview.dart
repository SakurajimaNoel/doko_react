import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';

String messagePreview(ChatMessage message, String username) {
  bool self = message.from == username;

  switch (message.subject) {
    case MessageSubject.text:
      return trimText(message.body);
    case MessageSubject.mediaBucketResource:
      String resourceType = getFileTypeFromPath(message.body);
      String remoteResponse = "Sent you a $resourceType.";
      String selfResponse = "You sent a $resourceType";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.mediaExternal:
      String remoteResponse = "${message.from} sent GIF / STICKER ️ 🖼️.";
      String selfResponse = "You sent GIF / STICKER ️ 🖼️.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.userLocation:
      String remoteResponse = "${message.from} sent a location.";
      String selfResponse = "You sent a location.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiUser:
      String remoteResponse = "${message.from} sent a User Profile.";
      String selfResponse = "You sent a User Profile.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiPost:
      String remoteResponse = "${message.from} sent a Post.";
      String selfResponse = "You sent a Post.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiPage:
      String remoteResponse = "${message.from} sent a Page.";
      String selfResponse = "You sent a Page.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiDiscussion:
      String remoteResponse = "${message.from} sent a Discussion.";
      String selfResponse = "You sent a Discussion.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiPolls:
      String remoteResponse = "${message.from} sent a Poll.";
      String selfResponse = "You sent a Poll.";

      return self ? selfResponse : remoteResponse;
  }
}
