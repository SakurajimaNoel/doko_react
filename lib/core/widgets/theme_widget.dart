import 'package:doko_react/core/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeWidget extends StatelessWidget {
  const ThemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProviderModel = Provider.of<ThemeProvider>(context);
    UserTheme userThemeView = themeProviderModel.themeMode;

    return Row(
      children: [
        Expanded(
          child: SegmentedButton<UserTheme>(
            segments: const <ButtonSegment<UserTheme>>[
              ButtonSegment<UserTheme>(
                  value: UserTheme.light,
                  label: Text('Light'),
                  icon: Icon(Icons.sunny)),
              ButtonSegment<UserTheme>(
                  value: UserTheme.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode)),
              ButtonSegment<UserTheme>(
                  value: UserTheme.system,
                  label: Text('System'),
                  icon: Icon(Icons.system_security_update_good_rounded)),
            ],
            selected: <UserTheme>{userThemeView},
            onSelectionChanged: (Set<UserTheme> newSelection) {
              themeProviderModel.toggleTheme(newSelection.first);
            },
          ),
        ),
      ],
    );
  }
}
