import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dreamshare/util/const.dart';
import 'package:dreamshare/util/theme_config.dart';
import 'package:dreamshare/views/screens/auth/login.dart';
import 'package:dreamshare/views/screens/main_screen.dart';
import 'package:dreamshare/services/api_client.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: themeData(ThemeConfig.lightTheme),
      darkTheme: themeData(ThemeConfig.darkTheme),
      home: FutureBuilder<bool>(
        future: ApiClient().hasToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) {
            return MainScreen();
          }
          return Login();
        },
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.interTextTheme(
        theme.textTheme,
      ),
    );
  }
}
