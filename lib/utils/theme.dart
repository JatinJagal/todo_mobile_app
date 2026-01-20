import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/utils/colors.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kWhite,
  appBarTheme: const AppBarTheme(
    surfaceTintColor: kPrimaryColor,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: kBlack,
    ),
  ),

  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    primary: kPrimaryColor,
    secondary: kLightPrimaryColor,
  ),
);
