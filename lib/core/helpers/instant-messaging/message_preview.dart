import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';

String messagePreview(ChatMessage message) {
  switch (message.subject) {
    case MessageSubject.text:
      return trimText(message.body);
    case MessageSubject.mediaBucketResource:
      String resourceType = getFileTypeFromPath(message.body);
      String response = "Sent you a $resourceType.";

      return response;
    case MessageSubject.mediaExternal:
      return "GIF / STICKER 🖼️";
    case MessageSubject.userLocation:
      return "${message.from} send you a location.";
    case MessageSubject.dokiUser:
      return "${message.from} sent a User Profile.";
    case MessageSubject.dokiPost:
      return "${message.from} sent a Post.";
    case MessageSubject.dokiPage:
      return "${message.from} sent a Page.";
    case MessageSubject.dokiDiscussion:
      return "${message.from} sent a Discussion.";
    case MessageSubject.dokiPolls:
      return "${message.from} sent a Poll.";
  }
}
