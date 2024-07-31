import 'package:doko_react/core/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProviderModel, child) => Scaffold(
          body: Column(
        children: [
          Text("Theme: ${themeProviderModel.themeMode}"),
          DropdownButton<String>(
              value: themeProviderModel.themeMode,
              items: themeProviderModel.themeModeList
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                print("working");
                if (value == null) return;
                themeProviderModel.toggleTheme(value);
              })
        ],
      )),
    );
  }
}
