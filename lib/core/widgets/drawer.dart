import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

class AppDrawerButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const AppDrawerButton({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: context.theme.iconButtonTheme.style,
      onPressed: () {
        scaffoldKey.currentState!.openDrawer();
      },
      icon: Icon(Icons.menu),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [

        ],
      ),
    );
  }
}