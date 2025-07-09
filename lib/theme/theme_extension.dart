import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  //============================ 🧠 Theme & Colors ============================//
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  //============================ 📐 MediaQuery ================================//
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  double get devicePixelRatio => mediaQuery.devicePixelRatio;
  double get viewPaddingTop => mediaQuery.viewPadding.top;
  double get viewPaddingBottom => mediaQuery.viewPadding.bottom;
  double get statusBarHeight => mediaQuery.viewPadding.top;
  bool get isKeyboardOpen => mediaQuery.viewInsets.bottom > 0;

  //============================ 💻 Device Type ===============================//
  double get _mobileMaxWidth => 600;
  double get _tabletMaxWidth => 1024;

  bool get isMobile => width < _mobileMaxWidth;
  bool get isTablet => width >= _mobileMaxWidth && width < _tabletMaxWidth;
  bool get isDesktop => width >= _tabletMaxWidth;

  //============================ 🔤 TextStyle Shortcuts =======================//
  TextStyle get h1 => textTheme.headlineLarge ?? const TextStyle();
  TextStyle get h2 => textTheme.headlineMedium ?? const TextStyle();
  TextStyle get h3 => textTheme.headlineSmall ?? const TextStyle();

  TextStyle get title1 => textTheme.titleLarge ?? const TextStyle();
  TextStyle get title2 => textTheme.titleMedium ?? const TextStyle();
  TextStyle get title3 => textTheme.titleSmall ?? const TextStyle();

  TextStyle get body1 => textTheme.bodyLarge ?? const TextStyle();
  TextStyle get body2 => textTheme.bodyMedium ?? const TextStyle();
  TextStyle get body3 => textTheme.bodySmall ?? const TextStyle();

  TextStyle get label1 => textTheme.labelLarge ?? const TextStyle();
  TextStyle get label2 => textTheme.labelMedium ?? const TextStyle();
  TextStyle get label3 => textTheme.labelSmall ?? const TextStyle();

  //============================ 🌐 Locale & Direction ========================//
  Locale get locale => Localizations.localeOf(this);
  TextDirection get direction => Directionality.of(this);
  bool get isRTL => direction == TextDirection.rtl;

  //============================ 🔁 Navigation ================================//
  void push(Widget page) =>
      Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  void pop<T extends Object?>([T? result]) => Navigator.pop(this, result);
  void pushReplacement(Widget page) =>
      Navigator.pushReplacement(this, MaterialPageRoute(builder: (_) => page));

  //============================ 🧼 Helpers ================================//
  void unfocus() => FocusScope.of(this).unfocus();

  void showSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  //============================== Poup =======================================

  Future<void> popup({
    required String title,
    required Widget content,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: this,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(this).pop();
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(this).pop();
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
