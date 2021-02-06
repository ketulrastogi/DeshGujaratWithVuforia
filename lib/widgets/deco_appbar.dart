import 'package:flutter/material.dart';

import '../config.dart';

class DecoNewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget bottom;
  final List<Widget> actions;

  DecoNewsAppBar(
      {Key key,
      this.title = Config.appTitle,
      this.centerTitle = true,
      this.elevation = 2.0,
      this.bottom,
      this.actions})
      : preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: centerTitle,
        elevation: elevation,
        iconTheme: IconThemeData(color: Color(0xFFAAB2B7)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: bottom,
        actions: actions);
  }
}
