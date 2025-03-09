import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

class MessageEntity implements GraphEntity {
  MessageEntity({
    required ChatMessage message,
    bool edited = false,
  })  : _message = message,
        _edited = edited;

  ChatMessage _message;
  bool _edited = false;

  ChatMessage get message => _message;

  bool get edited => _edited;

  int? listIndex;

  void editMessage(EditMessage message) {
    _message = _message.copyWith(
      body: message.body,
    );

    _setEdited();
  }

  void _setEdited() {
    _edited = true;
  }

  static MessageEntity createEntity(Map<String, dynamic> map) {
    ChatMessage message = ChatMessage(
      from: map["from"],
      to: map["to"],
      id: map["id"],
      subject: MessageSubject.fromValue(map["subject"]),
      body: map["body"],
      sendAt: DateTime.parse(map["createdAt"]).toLocal(),
      replyOn: map["replyFor"],
      forwarded: bool.parse(map["forwarded"]),
    );

    return MessageEntity(
      message: message,
      edited: bool.parse(map["edited"]),
    );
  }
}
