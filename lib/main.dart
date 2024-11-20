import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:doko_react/archive/core/widgets/error/error_text.dart';
import 'package:flutter/material.dart';

import 'aws/amplifyconfiguration.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();

    runApp(
      const MaterialApp(
        home: Center(
          child: Text("working file"),
        ),
      ),
    );
  } on AmplifyException catch (e) {
    runApp(
      MaterialApp(
        home: Center(
          child: ErrorText("Error configuring Amplify: ${e.message}"),
        ),
      ),
    );
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.addPlugin(AmplifyStorageS3());
    await Amplify.configure(amplifyconfig);

    safePrint("Successfully configured amplify");
  } on Exception catch (e) {
    safePrint("Error configuring Amplify: $e");
  }
}
