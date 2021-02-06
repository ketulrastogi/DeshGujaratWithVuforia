import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/helpers.dart';
import '../helpers/deco_localizations.dart';
import '../widgets/deco_appbar.dart';
import '../widgets/deco_news_drawer.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: adPadding(context: context),
      child: Scaffold(
        appBar: DecoNewsAppBar(),
        drawer: DecoNewsDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                child: Image.asset(
                  'images/deco_logo.png',
                  scale: 3.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'DeshGujarat News',
                  style: TextStyle(
                    color: isDark ? Colors.white : Color(0xFF1B1E28),
                    fontSize: 20.0,
                  ),
                ),
              ),
              Container(
                // width: 220.0,
                padding: EdgeInsets.only(
                  bottom: 60.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Text(
                  'DeshGujarat is one of most credible news and information service portals based in Gujarat. Based in Ahmedabad in Gujarat since 2006, DeshGujarat mainly covers Gujarat area',
                  style: TextStyle(
                    color: Color(0xFF7F7E96),
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            width: double.infinity,
            height: 55.0,
            margin: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 10.0),
            child: RaisedButton(
              onPressed: () async {
                const url = 'https://www.deshgujarat.com/';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              padding: EdgeInsets.all(0),
              color: isDark ? Colors.white : Color(0xFF1B1E28),
              textColor: isDark ? Color(0xFF1B1E28) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Text('Contact Now'),
            ),
          ),
        ),
      ),
    );
  }
}
