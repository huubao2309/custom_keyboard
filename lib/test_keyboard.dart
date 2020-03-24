part of lib_custom_keyboard;

class CustomKeyboardDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CustomKeyboardDemoState();
  }
}

class CustomKeyboardDemoState extends State<CustomKeyboardDemo> {
  TextEditingController textEditingController =
      TextEditingController(text: 'test');
  TextEditingController textEditing2Controller =
      TextEditingController(text: 'test');

  @override
  Widget build(BuildContext context) {
    return KeyboardMediaQuery(child: Builder(builder: (ctx) {
      // CoolKeyboard.init(ctx);
      return Scaffold(
          appBar: AppBar(
            title: Text("Custom Keyboard Demo"),
          ),
          body: ListView(
            children: <Widget>[
              TextField(
                controller: textEditingController,
                keyboardType: TextInputType.text,
              ),
              Container(
                height: 300.0,
              ),
              TextField(
                controller: textEditing2Controller,
                decoration: InputDecoration(labelText: 'Label test 1'),
                keyboardType: NumberKeyboard.inputType,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Label test 2'),
                keyboardType: NumberKeyboard.inputType,
              )
            ],
          ));
    }));
  }
}
