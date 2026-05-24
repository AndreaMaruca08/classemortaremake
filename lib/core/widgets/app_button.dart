
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final double width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.isLoading = false,
    this.width = 50,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.colorScheme.primary,
          foregroundColor: foregroundColor ?? context.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? AppBorderRadius.large,
          ),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(text, style: context.textTheme.bodyMedium),
      ),
    );
  }
}
