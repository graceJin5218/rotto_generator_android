import 'package:flutter/material.dart';

const kMainColor = Color(0xFF22223B);
const kAccentColor = Color(0xFFFFD600);

final lottoTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: kAccentColor, brightness: Brightness.light),
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'SUIT',
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    centerTitle: true,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: kMainColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: kMainColor),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    elevation: 0.5,
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccentColor,
      foregroundColor: kMainColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      minimumSize: const Size.fromHeight(48),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kMainColor),
    bodyMedium: TextStyle(color: kMainColor),
    labelLarge: TextStyle(color: kMainColor),
  ),
  useMaterial3: true,
);
