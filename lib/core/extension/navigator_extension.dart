import 'package:flutter/material.dart';

extension NavigatorExtension on BuildContext {
  Future<T?> pushTo<T>(Widget page) {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void pop<T>([T? result]) {
    Navigator.pop<T>(this, result);
  }

  Future<T?> pushReplacement<T, TO>(Widget page) {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}