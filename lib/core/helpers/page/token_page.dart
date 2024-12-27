import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TokenPage extends StatelessWidget {
  const TokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Get user tokens"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: Constants.gap * 3,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final token = await getUserToken();
                Clipboard.setData(ClipboardData(
                  text: token.accessToken,
                )).then((value) {});
              },
              child: Text("access token"),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final token = await getUserToken();
                Clipboard.setData(ClipboardData(
                  text: token.idToken,
                )).then((value) {});
              },
              child: Text("id token"),
            ),
          ),
        ],
      ),
    );
  }
}
