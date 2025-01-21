import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:flutter/material.dart';

class WebsocketClientProvider extends ChangeNotifier {
  WebsocketClientProvider({
    required this.client,
  });

  final Client client;
}
