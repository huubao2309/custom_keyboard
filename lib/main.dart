import 'package:flutter/material.dart';

import 'lib_custom_keyboard.dart';

void main() {
  NumberKeyboard.register();
  runApp(
    KeyboardRootWidget(
      child: MyApp(),
    ),
  ); //Added KeyboardRootWidget
}
