import 'package:flutter/material.dart';
import '../helpers/deco_localizations.dart';

class NoData extends StatelessWidget {
  final String message;

  NoData(this.message);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Image.asset('images/deco_logo.png'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Text(
              DecoLocalizations.of(context).localizedString("no_data"),
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1B1E28),
                fontSize: 20.0,
              ),
            ),
          ),
          Container(
            width: 220.0,
            child: Text(
              message,
              style: TextStyle(
                color: Color(0xFF7F7E96),
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
