part of lib_custom_keyboard;

typedef GetKeyboardHeight = double Function(BuildContext context);
typedef KeyboardBuilder = Widget Function(
    BuildContext context, KeyboardController controller, String param);

class CoolKeyboard {
  static JSONMethodCodec _codec = const JSONMethodCodec();
  static KeyboardConfig _currentKeyboard;
  static Map<CKTextInputType, KeyboardConfig> _keyboards = {};
  static BuildContext _context;
  static OverlayEntry _keyboardEntry;
  static KeyboardController _keyboardController;
  static GlobalKey<KeyboardPageState> _pageKey;
  static bool isInterceptor = false;

  static ValueNotifier<double> _keyboardHeightNotifier = ValueNotifier(null)
    ..addListener(updateKeyboardHeight);

  static String _keyboardParam;

  static init(BuildContext context) {
    _context = context;
    interceptorInput();
  }

  static interceptorInput() {
    if (isInterceptor) return;
    isInterceptor = true;
    ServicesBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler("flutter/textinput", (ByteData data) async {
      var methodCall = _codec.decodeMethodCall(data);
      switch (methodCall.method) {
        case 'TextInput.show':
          if (_currentKeyboard != null) {
            openKeyboard();
            return _codec.encodeSuccessEnvelope(null);
          } else {
            return await _sendPlatformMessage("flutter/textinput", data);
          }
          break;
        case 'TextInput.hide':
          if (_currentKeyboard != null) {
            hideKeyboard();
            return _codec.encodeSuccessEnvelope(null);
          } else {
            return await _sendPlatformMessage("flutter/textinput", data);
          }
          break;
        case 'TextInput.setEditingState':
          var editingState = TextEditingValue.fromJSON(methodCall.arguments);
          if (editingState != null && _keyboardController != null) {
            _keyboardController.value = editingState;
            return _codec.encodeSuccessEnvelope(null);
          }
          break;
        case 'TextInput.clearClient':
          hideKeyboard(animation: true);
          clearKeyboard();
          break;
        case 'TextInput.setClient':
          var setInputType = methodCall.arguments[1]['inputType'];
          InputClient client;
          _keyboards.forEach((inputType, keyboardConfig) {
            if (inputType.name == setInputType['name']) {
              client = InputClient.fromJSON(methodCall.arguments);

              _keyboardParam =
                  (client.configuration.inputType as CKTextInputType).params;

              clearKeyboard();
              _currentKeyboard = keyboardConfig;
              _keyboardController = KeyboardController(client: client)
                ..addListener(() {
                  var callbackMethodCall = MethodCall(
                      "TextInputClient.updateEditingState", [
                    _keyboardController.client.connectionId,
                    _keyboardController.value.toJSON()
                  ]);
                  ServicesBinding.instance.defaultBinaryMessenger
                      .handlePlatformMessage(
                          "flutter/textinput",
                          _codec.encodeMethodCall(callbackMethodCall),
                          (data) {});
                });
              if (_pageKey != null) {
                _pageKey.currentState?.update();
              }
            }
          });

          if (client != null) {
            await _sendPlatformMessage("flutter/textinput",
                _codec.encodeMethodCall(MethodCall('TextInput.hide')));
            return _codec.encodeSuccessEnvelope(null);
          } else {
            hideKeyboard(animation: false);
            clearKeyboard();
          }
          break;
      }
      ByteData response = await _sendPlatformMessage("flutter/textinput", data);
      return response;
    });
  }

  static Future<ByteData> _sendPlatformMessage(
      String channel, ByteData message) {
    final Completer<ByteData> completer = Completer<ByteData>();
    ui.window.sendPlatformMessage(channel, message, (ByteData reply) {
      try {
        completer.complete(reply);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context:
              ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }

  static addKeyboard(CKTextInputType inputType, KeyboardConfig config) {
    _keyboards[inputType] = config;
  }

  static openKeyboard() {
    var keyboardHeight = _currentKeyboard.getHeight(_context);
    _keyboardHeightNotifier.value = keyboardHeight;
    if (_keyboardEntry != null) return;
    _pageKey = GlobalKey<KeyboardPageState>();
    // KeyboardMediaQueryState queryState = _context
    //         .ancestorStateOfType(const TypeMatcher<KeyboardMediaQueryState>())
    //     as KeyboardMediaQueryState;
    // queryState.update();

    var tempKey = _pageKey;
    _keyboardEntry = OverlayEntry(builder: (ctx) {
      if (_currentKeyboard != null && _keyboardHeightNotifier.value != null) {
        return KeyboardPage(
            key: tempKey,
            builder: (ctx) {
              return _currentKeyboard?.builder(
                  ctx, _keyboardController, _keyboardParam);
            },
            height: _keyboardHeightNotifier.value);
      } else {
        return Container();
      }
    });

    Overlay.of(_context).insert(_keyboardEntry);

    BackButtonInterceptor.add((_) {
      CoolKeyboard.sendPerformAction(TextInputAction.done);
      return true;
    }, zIndex: 1, name: 'CustomKeyboard');
  }

  static hideKeyboard({bool animation = true}) {
    BackButtonInterceptor.removeByName('CustomKeyboard');
    if (_keyboardEntry != null && _pageKey != null) {
      _keyboardHeightNotifier.value = null;
      // _pageKey.currentState.animationController
      //     .addStatusListener((AnimationStatus status) {
      //   if (status == AnimationStatus.dismissed ||
      //       status == AnimationStatus.completed) {
      //     if (_keyboardEntry != null) {
      //       _keyboardEntry.remove();
      //       _keyboardEntry = null;
      //     }
      //   }
      // });
      if (animation) {
        _pageKey.currentState.exitKeyboard();
        Future.delayed(Duration(milliseconds: 116)).then((_) {
          if (_keyboardEntry != null) {
            _keyboardEntry.remove();
            _keyboardEntry = null;
          }
        });
      } else {
        _keyboardEntry.remove();
        _keyboardEntry = null;
      }
    }
    _pageKey = null;
    try {
      // KeyboardMediaQueryState queryState = _context
      //     .ancestorStateOfType(const TypeMatcher<KeyboardMediaQueryState>())
      // as KeyboardMediaQueryState;
      // queryState.update();
    } catch (_) {}
  }

  static clearKeyboard() {
    _currentKeyboard = null;
    if (_keyboardController != null) {
      _keyboardController.dispose();
      _keyboardController = null;
    }
  }

  static sendPerformAction(TextInputAction action) {
    var callbackMethodCall = MethodCall("TextInputClient.performAction",
        [_keyboardController.client.connectionId, action.toString()]);
    ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        "flutter/textinput",
        _codec.encodeMethodCall(callbackMethodCall),
        (data) {});
  }

  static updateKeyboardHeight() {
    if (_pageKey != null && _pageKey.currentState != null) {
      _pageKey.currentState.updateHeight(_keyboardHeightNotifier.value);
    }
  }
}

class KeyboardConfig {
  final KeyboardBuilder builder;
  final GetKeyboardHeight getHeight;
  const KeyboardConfig({this.builder, this.getHeight});
}

class InputClient {
  final int connectionId;
  final TextInputConfiguration configuration;
  const InputClient({this.connectionId, this.configuration});

  factory InputClient.fromJSON(List<dynamic> encoded) {
    return InputClient(
        connectionId: encoded[0],
        configuration: TextInputConfiguration(
            inputType: CKTextInputType.fromJSON(encoded[1]['inputType']),
            obscureText: encoded[1]['obscureText'],
            autocorrect: encoded[1]['autocorrect'],
            actionLabel: encoded[1]['actionLabel'],
            inputAction: _toTextInputAction(encoded[1]['inputAction']),
            textCapitalization:
                _toTextCapitalization(encoded[1]['textCapitalization']),
            keyboardAppearance:
                _toBrightness(encoded[1]['keyboardAppearance'])));
  }

  static TextInputAction _toTextInputAction(String action) {
    switch (action) {
      case 'TextInputAction.none':
        return TextInputAction.none;
      case 'TextInputAction.unspecified':
        return TextInputAction.unspecified;
      case 'TextInputAction.go':
        return TextInputAction.go;
      case 'TextInputAction.search':
        return TextInputAction.search;
      case 'TextInputAction.send':
        return TextInputAction.send;
      case 'TextInputAction.next':
        return TextInputAction.next;
      case 'TextInputAction.previuos':
        return TextInputAction.previous;
      case 'TextInputAction.continue_action':
        return TextInputAction.continueAction;
      case 'TextInputAction.join':
        return TextInputAction.join;
      case 'TextInputAction.route':
        return TextInputAction.route;
      case 'TextInputAction.emergencyCall':
        return TextInputAction.emergencyCall;
      case 'TextInputAction.done':
        return TextInputAction.done;
      case 'TextInputAction.newline':
        return TextInputAction.newline;
    }
    throw FlutterError('Unknown text input action: $action');
  }

  static TextCapitalization _toTextCapitalization(String capitalization) {
    switch (capitalization) {
      case 'TextCapitalization.none':
        return TextCapitalization.none;
      case 'TextCapitalization.characters':
        return TextCapitalization.characters;
      case 'TextCapitalization.sentences':
        return TextCapitalization.sentences;
      case 'TextCapitalization.words':
        return TextCapitalization.words;
    }

    throw FlutterError('Unknown text capitalization: $capitalization');
  }

  static Brightness _toBrightness(String brightness) {
    switch (brightness) {
      case 'Brightness.dark':
        return Brightness.dark;
      case 'Brightness.light':
        return Brightness.light;
    }

    throw FlutterError('Unknown Brightness: $brightness');
  }
}

class CKTextInputType extends TextInputType {
  final String name;
  final String params;

  const CKTextInputType({this.name, bool signed, bool decimal, this.params})
      : super.numberWithOptions(signed: signed, decimal: decimal);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'signed': signed,
      'decimal': decimal,
      'params': params
    };
  }

  @override
  String toString() {
    return '$runtimeType('
        'name: $name, '
        'signed: $signed, '
        'decimal: $decimal)';
  }

  bool operator ==(Object target) {
    if (target is CKTextInputType) {
      if (this.name == target.toString()) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => this.toString().hashCode;

  factory CKTextInputType.fromJSON(Map<String, dynamic> encoded) {
    return CKTextInputType(
        name: encoded['name'],
        signed: encoded['signed'],
        decimal: encoded['decimal'],
        params: encoded['params']);
  }
}

class KeyboardPage extends StatefulWidget {
  final WidgetBuilder builder;
  final double height;
  const KeyboardPage({this.builder, this.height, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => KeyboardPageState();
}

class KeyboardPageState extends State<KeyboardPage> {
  Widget _lastBuildWidget;
  bool isClose = false;
  double _height = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1)).then((_) {
      setState(() {
        _height = widget.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      child: IntrinsicHeight(child: Builder(
        builder: (ctx) {
          var result = widget.builder(ctx);
          if (result != null) {
            _lastBuildWidget = result;
          }
          return ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: _height,
                maxWidth: _ScreenUtil.getScreenW(context)),
            child: _lastBuildWidget,
          );
        },
      )),
      left: 0,
      width: _ScreenUtil.getScreenW(context),
      bottom: _height * (isClose ? -1 : 0),
      height: _height,
      duration: Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    // if (animationController.status == AnimationStatus.forward ||
    //     animationController.status == AnimationStatus.reverse) {
    //   animationController.notifyStatusListeners(AnimationStatus.dismissed);
    // }
    // animationController.dispose();
    super.dispose();
  }

  exitKeyboard() {
    isClose = true;
  }

  update() {
    try {
      setState(() => {});
    } catch (_) {}
  }

  updateHeight(double height) {
    try {
      this._height = height ?? 0;
      setState(() => {});
    } catch (_) {}
  }
}
