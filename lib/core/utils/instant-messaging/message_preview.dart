import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';

/// delete text
const String selfDeleteText = "You deleted the message.";
String remoteDeleteText(String username) {
  return "@$username deleted the message.";
}

/// edit text
const String selfEditText = "You edited the message.";
String remoteEditText(String username) {
  return "@$username edited the message.";
}

String messagePreview(ChatMessage message, String username) {
  bool self = message.from == username;

  switch (message.subject) {
    case MessageSubject.text:
      return trimText(message.body);
    case MessageSubject.mediaBucketResource:
      String resourceType = getFileTypeFromPath(message.body);
      String remoteResponse = "@${message.from} sent you a $resourceType.";
      String selfResponse = "You sent a $resourceType";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.mediaExternal:
      String remoteResponse = "@${message.from} sent GIF / STICKER ️ 🖼️.";
      String selfResponse = "You sent GIF / STICKER ️ 🖼️.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.userLocation:
      String remoteResponse = "@${message.from} sent a location.";
      String selfResponse = "You sent a location.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiUser:
      String remoteResponse = "@${message.from} sent a User Profile.";
      String selfResponse = "You sent a User Profile.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiPost:
      String remoteResponse = "@${message.from} sent a Post.";
      String selfResponse = "You sent a Post.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiPage:
      String remoteResponse = "@${message.from} sent a Page.";
      String selfResponse = "You sent a Page.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiDiscussion:
      String remoteResponse = "@${message.from} sent a Discussion.";
      String selfResponse = "You sent a Discussion.";

      return self ? selfResponse : remoteResponse;
    case MessageSubject.dokiPolls:
      String remoteResponse = "@${message.from} sent a Poll.";
      String selfResponse = "You sent a Poll.";

      return self ? selfResponse : remoteResponse;
  }
}

String messageReplyPreview(MessageSubject subject, String body) {
  String displayMessageReply;

  switch (subject) {
    case MessageSubject.text:
      displayMessageReply = trimText(
        body,
        len: 32,
      );
    case MessageSubject.mediaBucketResource:
      displayMessageReply = "MEDIA";
    case MessageSubject.mediaExternal:
      displayMessageReply = "GIF / STICKER 🖼️";
    case MessageSubject.userLocation:
      displayMessageReply = "LOCATION";
    case MessageSubject.dokiUser:
      displayMessageReply = "USER Profile";
    case MessageSubject.dokiPost:
      displayMessageReply = "POST";
    case MessageSubject.dokiPage:
      displayMessageReply = "PAGE";
    case MessageSubject.dokiDiscussion:
      displayMessageReply = "DISCUSSION";
    case MessageSubject.dokiPolls:
      displayMessageReply = "POLLS";
  }

  return displayMessageReply;
}
