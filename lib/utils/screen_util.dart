part of lib_custom_keyboard;

/// Default design draft size (unit dp or pt)
double _designW = 360.0;
double _designH = 640.0;
double _designD = 3.0;

/*
 * Default design size（unit dp or pt）
 * w: wide
 * h: high
 * density: pixel density
 */
void setDesignWHD(double w, double h, {double density: 3.0}) {
  _designW = w;
  _designH = h;
  _designD = density;
}

/// Screen Util.
class _ScreenUtil {
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  double _screenDensity = 0.0;
  double _statusBarHeight = 0.0;
  double _bottomBarHeight = 0.0;
  double _appBarHeight = 0.0;
  double _textScaleFactor = 0.0;
  MediaQueryData _mediaQueryData;

  static final _ScreenUtil _singleton = _ScreenUtil();

  static _ScreenUtil getInstance() {
    _singleton._init();
    return _singleton;
  }

  _init() {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    if (_mediaQueryData != mediaQuery) {
      _mediaQueryData = mediaQuery;
      _screenWidth = mediaQuery.size.width;
      _screenHeight = mediaQuery.size.height;
      _screenDensity = mediaQuery.devicePixelRatio;
      _statusBarHeight = mediaQuery.padding.top;
      _bottomBarHeight = mediaQuery.padding.bottom;
      _textScaleFactor = mediaQuery.textScaleFactor;
      _appBarHeight = kToolbarHeight;
    }
  }

  /// screen width
  double get screenWidth => _screenWidth;

  /// screen height
  double get screenHeight => _screenHeight;

  /// appBar height
  double get appBarHeight => _appBarHeight;

  /// screen density
  double get screenDensity => _screenDensity;

  /// status bar Height
  double get statusBarHeight => _statusBarHeight;

  /// bottom bar Height
  double get bottomBarHeight => _bottomBarHeight;

  /// media Query Data
  MediaQueryData get mediaQueryData => _mediaQueryData;

  /// screen width
  static double getScreenW(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width;
  }

  /// screen height
  static double getScreenH(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width;
  }

  /// screen density
  static double getScreenDensity(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.devicePixelRatio;
  }

  /// status bar Height
  static double getStatusBarH(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.top;
  }

  /// status bar Height
  static double getBottomBarH(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.bottom;
  }

  /// Current MediaQueryData
  static MediaQueryData getMediaQueryData(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery;
  }

  /// Returns the size according to the screen width (in dp or pt)
  /// size unit dp or pt
  static double getScaleW(BuildContext context, double size) {
    if (context == null || getScreenW(context) == 0.0) return size;
    return size * getScreenW(context) / _designW;
  }

  /// Returns the size after the screen height is adapted (unit dp or pt)
  /// size unit dp or pt
  static double getScaleH(BuildContext context, double size) {
    if (context == null || getScreenH(context) == 0.0) return size;
    return size * getScreenH(context) / _designH;
  }

  /// Returns the font size after adapting to the screen width
  /// fontSize font size
  /// Whether sySystem follows the system font size setting. The default is true.
  static double getScaleSp(BuildContext context, double fontSize,
      {bool sySystem: true}) {
    if (context == null || getScreenW(context) == 0.0) return fontSize;
    return (sySystem ? MediaQuery.of(context).textScaleFactor : 1.0) *
        fontSize *
        getScreenW(context) /
        _designW;
  }

  /// Orientation
  /// device orientation (portrait, landscape)
  static Orientation getOrientation(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation;
  }

  /// Returns the size after the screen width is adapted (unit dp or pt)
  /// size unit dp or pt
  double getWidth(double size) {
    return _screenWidth == 0.0 ? size : (size * _screenWidth / _designW);
  }

  /// Returns the size after the screen height is adapted (unit dp or pt)
  /// size unit dp or pt
  double getHeight(double size) {
    return _screenHeight == 0.0 ? size : (size * _screenHeight / _designH);
  }

  /// Returns the size after the screen width is adapted (unit dp or pt)
  /// sizePx unit px
  double getWidthPx(double sizePx) {
    return _screenWidth == 0.0
        ? (sizePx / _designD)
        : (sizePx * _screenWidth / (_designW * _designD));
  }

  /// Returns the size after the screen height is adapted (unit dp or pt)
  /// sizePx unit px
  double getHeightPx(double sizePx) {
    return _screenHeight == 0.0
        ? (sizePx / _designD)
        : (sizePx * _screenHeight / (_designH * _designD));
  }

  /// Returns the font size after adapting to the screen width
  /// fontSize font size
  /// Whether sySystem follows the system font size setting. The default is true.
  double getSp(double fontSize, {bool sySystem: true}) {
    if (_screenWidth == 0.0) return fontSize;
    return (sySystem ? _textScaleFactor : 1.0) *
        fontSize *
        _screenWidth /
        _designW;
  }
}
