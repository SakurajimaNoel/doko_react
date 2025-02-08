import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

class MessageEntity implements GraphEntity {
  MessageEntity({
    required ChatMessage message,
  }) : _message = message;

  ChatMessage _message;
  bool _edited = false;
  bool _deleted = false;

  ChatMessage get message => _message;

  bool get edited => _edited;

  bool get deleted => _deleted;

  void editMessage(EditMessage message) {
    _message = _message.updateMessage(
      body: message.body,
    );

    _setEdited();
  }

  void deleteMessage() {
    _deleted = true;
  }

  void _setEdited() {
    _edited = true;
  }
}
