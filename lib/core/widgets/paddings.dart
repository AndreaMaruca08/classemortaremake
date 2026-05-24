import 'package:flutter/cupertino.dart';

class HPadding extends StatelessWidget {
  final Widget child;
  const HPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
  }
}

class VPadding extends StatelessWidget {
  final Widget child;
  const VPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: child,
    );
  }
}

class FullPadding extends StatelessWidget {
  final Widget child;
  const FullPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: child,
    );
  }
}
