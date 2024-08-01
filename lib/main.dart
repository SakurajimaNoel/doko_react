import 'package:doko_react/core/provider/theme_provider.dart';
import 'package:doko_react/core/theme/theme_data.dart';
import 'package:doko_react/features/authentication/presentation/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    ThemeMode themeMode;

    switch (theme.themeMode) {
      case UserTheme.light:
        themeMode = ThemeMode.light;
        break;
      case UserTheme.dark:
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dokii',
        themeMode: themeMode,
        theme: GlobalThemeData.lightThemeData,
        darkTheme: GlobalThemeData.darkThemeData,
        home: const LoginPage());
  }
}
