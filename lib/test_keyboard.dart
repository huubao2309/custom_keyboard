part of lib_custom_keyboard;

class CustomKeyboardDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CustomKeyboardDemoState();
  }
}

class CustomKeyboardDemoState extends State<CustomKeyboardDemo> {
  TextEditingController textEditingController =
      TextEditingController(text: 'Default Text Keyboard');
  TextEditingController textEditing2Controller =
      TextEditingController(text: 'Default Number Keyboard');
  TextEditingController textEditing3Controller =
      TextEditingController(text: 'Custom Number Keyboard');

  @override
  Widget build(BuildContext context) {
    return KeyboardMediaQuery(child: Builder(builder: (ctx) {
      // CoolKeyboard.init(ctx);
      return Scaffold(
          appBar: AppBar(
            title: Text("Custom Keyboard Demo"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: <Widget>[
                TextField(
                  controller: textEditingController,
                  keyboardType: TextInputType.text,
                ),
                TextField(
                  controller: textEditing2Controller,
                  keyboardType: TextInputType.number,
                ),
                Container(
                  height: 250.0,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      'Space for testing scroll \nWhen KeyBoard is show',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: textEditing3Controller,
                  decoration: InputDecoration(labelText: 'Label Field 1'),
                  keyboardType: NumberKeyboard.inputType,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Label Field 2'),
                  keyboardType: NumberKeyboard.inputType,
                )
              ],
            ),
          ));
    }));
  }
}
