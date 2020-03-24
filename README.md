# Custom Keyboard

![Custom Keyboard](https://github.com/huubao2309/custom_keyboard/blob/master/images/custom_keyboard.gif)

## Setup

### 1. Project has use lib "back_button_interceptor" at `pubspec.yaml` file:

```dart
dependencies:
  back_button_interceptor: ^4.0.6
```

### 2. Use for your screen:

```dart
 //Added KeyboardRootWidget
 home: KeyboardRootWidget(
     child: ...,
 ),
```

### 3. Use at TextField:

```dart
   TextField(
       controller: textEditingController,
       decoration: InputDecoration(labelText: 'label text'),
       keyboardType: NumberKeyboard.inputType, // Call at Keyboard type
   ),
```
