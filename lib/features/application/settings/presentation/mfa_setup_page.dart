import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/features/application/settings/presentation/verify_mfa_page.dart';
import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/presentation/widgets/error_widget.dart';

class MfaSetupPage extends StatefulWidget {
  const MfaSetupPage({super.key});

  @override
  State<MfaSetupPage> createState() => _MfaSetupPageState();
}

class _MfaSetupPageState extends State<MfaSetupPage> {
  String _errorMessage = "";
  bool _loading = true;
  String _key = "";
  String _uri = "";
  static const double _padding = 16;

  @override
  void initState() {
    super.initState();

    _setupMFA();
  }

  void _setupMFA() async {
    var setupMfaResult = await AuthenticationActions.setupMfa();

    setState(() {
      _loading = false;
    });

    if (setupMfaResult.status == AuthStatus.error) {
      setState(() {
        _errorMessage = setupMfaResult.message ?? "";
      });
      return;
    }

    var url = setupMfaResult.url;
    var secret = setupMfaResult.message;

    if (url == null || secret == null) {
      return;
    }

    setState(() {
      _key = secret;
      _uri = url.toString();
    });

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      safePrint("Can't open authenticator app");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    String trimKey = DisplayText.trimText(_key, len: 30);

    return Scaffold(
      appBar: AppBar(
        title: const SettingsHeading(
          "MFA Setup",
        ),
      ),
      body: _loading
          ? const Center(
              // Centering the CircularProgressIndicator
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(),
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  // Centering the CircularProgressIndicator
                  child: ErrorText(_errorMessage),
                )
              : Padding(
                  padding: const EdgeInsets.all(_padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_uri.isNotEmpty) ...[
                        const Text(
                            "To enable extra security, scan the QR code with your authenticator app"),
                        const SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: QrImageView(
                            data: _uri,
                            version: QrVersions.auto,
                            size: 225.0,
                            backgroundColor: currTheme.surface,
                            eyeStyle: QrEyeStyle(
                              color: currTheme.onSurface,
                              eyeShape: QrEyeShape.square,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              color: currTheme.onSurface,
                              dataModuleShape: QrDataModuleShape.square,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        RichText(
                          text: TextSpan(
                            text: "or manually enter the secret key ",
                            style: TextStyle(color: currTheme.onSurface),
                            children: [
                              TextSpan(
                                  text: trimKey,
                                  style: TextStyle(
                                    color: currTheme.primary,
                                    fontWeight: FontWeight.w500,
                                  )),
                              const TextSpan(
                                  text:
                                      " into the authenticator app to set up multi-factor authentication for your account.")
                            ],
                          ),
                        ),
                        TextButton(
                            style: const ButtonStyle(
                                padding:
                                    WidgetStatePropertyAll(EdgeInsets.zero)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _key))
                                  .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "successfully copied secret to clipboard")));
                              });
                            },
                            child: const Text("Copy secret code")),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const VerifyMfaPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 24),
                            backgroundColor: currTheme.primary,
                            foregroundColor: currTheme.onPrimary,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text("Continue"),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
    );
  }
}