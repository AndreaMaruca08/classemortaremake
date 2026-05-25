import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';

import 'drawer.dart';

class PageTitle extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String text;
  const PageTitle({super.key, required this.text, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        44.height,
        Row(children: [
          12.width,
          AppDrawerButton(scaffoldKey: scaffoldKey),
          12.width,
          Expanded(
            child: Text(
              text,
              style: context.textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          12.width,
        ]),
      ],
    );
  }
}
