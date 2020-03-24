part of lib_custom_keyboard;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Custom Keyboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CustomKeyboardDemo(),
    );
  }
}
