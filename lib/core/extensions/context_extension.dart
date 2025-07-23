import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Theme & Colors
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Text Styles
  TextStyle? get h1 => textTheme.displayLarge;
  TextStyle? get body2 => textTheme.bodyMedium;

  // MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  bool get isKeyboardOpen => mediaQuery.viewInsets.bottom > 0;

  // Device Type
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  // Navigation
  void push(Widget page) =>
      Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  void pop<T extends Object?>([T? result]) => Navigator.pop(this, result);
  void pushReplacement(Widget page) =>
      Navigator.pushReplacement(this, MaterialPageRoute(builder: (_) => page));

  // Helpers
  void unfocus() => FocusScope.of(this).unfocus();

  // SnackBar --------------------------------------------------------------------

  void showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<bool?> popup({
    required String title,
    required Widget content,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(this).pop(false);
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(this).pop(true);
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
