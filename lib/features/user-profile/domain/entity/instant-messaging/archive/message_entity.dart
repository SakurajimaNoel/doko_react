import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

class MessageEntity extends GraphEntity {
  MessageEntity({
    required ChatMessage message,
  }) : _message = message;

  ChatMessage _message;

  ChatMessage get message => _message;

  void editMessage(EditMessage message) {
    _message = _message.updateMessage(
      body: message.body,
    );
  }
}
