import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:flutter/material.dart';

class WebsocketClientProvider extends ChangeNotifier {
  WebsocketClientProvider();

  Client? client;

  void addClient(Client client) {
    this.client = client;

    notifyListeners();
  }
}
