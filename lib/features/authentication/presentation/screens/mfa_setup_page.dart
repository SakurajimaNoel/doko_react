import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MfaSetupPage extends StatefulWidget {
  const MfaSetupPage({super.key});

  @override
  State<MfaSetupPage> createState() => _MfaSetupPageState();
}

class _MfaSetupPageState extends State<MfaSetupPage> {
  String _code = "";

  @override
  Widget build(BuildContext context) {
    final currScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("user feed!"),
            ElevatedButton(
                onPressed: () async {
                  var result = await AuthenticationActions.setupMfa();
                  var url = result.url;
                  var secret = result.message;
                  if (result.status == AuthStatus.done &&
                      url != null &&
                      secret != null) {
                    setState(() {
                      _code = url.toString();
                    });
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      safePrint("Can't open authenticator app");
                    }
                  }
                },
                child: const Text("open authenticator app")),
            if (_code.isNotEmpty) ...[
              QrImageView(
                data: _code,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: currScheme.surface,
                eyeStyle: QrEyeStyle(
                  color: currScheme.onSurface,
                  eyeShape: QrEyeShape.square,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  color: currScheme.onSurface,
                  dataModuleShape: QrDataModuleShape.square,
                ),
              ),
              TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _code)).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("successfully copied secret to clipboard")));
                    });
                  },
                  child: const Text("Copy secret code"))
            ]
          ],
        ),
      ),
    );
  }
}
