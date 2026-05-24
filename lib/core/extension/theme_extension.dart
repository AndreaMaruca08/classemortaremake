import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  BoxDecoration get containerDecoration => BoxDecoration(
    color: colorScheme.surface,
    borderRadius: AppBorderRadius.large,
  );

  Size get screenSize =>
      MediaQuery
          .of(this)
          .size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isPortrait =>
      MediaQuery
          .of(this)
          .orientation == Orientation.portrait;
}