import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
      surface: Colors.grey.shade300,
      primary: Colors.grey.shade500,
      secondary: Colors.grey.shade100,
      tertiary: Colors.white,
      inversePrimary: Colors.grey.shade700
  ),
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
      surface: Color.fromARGB(255, 20, 20, 20),
      primary: Color.fromARGB(255, 122, 122, 122),
      secondary: Color.fromARGB(255, 30, 30, 30),
      tertiary: Color.fromARGB(255, 47, 47, 47),
      inversePrimary: Colors.grey.shade300
  ),
);