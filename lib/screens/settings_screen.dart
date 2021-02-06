import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/helpers.dart';
import '../helpers/deco_localizations.dart';
import '../config.dart';
import '../widgets/deco_appbar.dart';
import '../widgets/deco_news_drawer.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _rtlEnabled = true;

  @override
  void initState() {
    super.initState();

    _areNotificationsEnabled();

    _isRTLEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: adPadding(context: context),
      child: Scaffold(
        appBar: DecoNewsAppBar(),
        drawer: DecoNewsDrawer(),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[

              Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withOpacity(0.13)
                    )
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Text(DecoLocalizations.of(context).localizedString("enable_push_notifications")),

                    Switch(
                      onChanged: (bool enabled) {
                        setState(() {
                          _notificationsEnabled = enabled;
                          _updateNotifications(enabled);
                        });
                      },
                      value: _notificationsEnabled,
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.black.withOpacity(0.13)
                        )
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Text(DecoLocalizations.of(context).localizedString("enable_right_to_left")),

                    Switch(
                      onChanged: (bool enabled) {
                        setState(() {
                          if(Config.defaultLocale != 'ar') {
                            _rtlEnabled = enabled;
                            _updateRTL(enabled);
                          }
                        });
                      },
                      value: _rtlEnabled,
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                child: OutlineButton(
                  onPressed: () {
                    DecoNews.of(context).setBrightness(Brightness.light);
                  },

                  child: Text(DecoLocalizations.of(context).localizedString("light_mode"), style: TextStyle(color: Colors.blue),),
                  borderSide: BorderSide(
                    color: Colors.blue
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                child: OutlineButton(
                  onPressed: () {
                    DecoNews.of(context).setBrightness(Brightness.dark);
                  },

                  child: Text(DecoLocalizations.of(context).localizedString("dark_mode"), style: TextStyle(color: Colors.blue),),
                  borderSide: BorderSide(
                    color: Colors.blue
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Checks are notifications enabled
  Future<void> _areNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificationsEnabled = (prefs.getBool('isPushNotificationEnabled') ?? true);
    });
  }

  /// Enables or disables notifications
  Future<void> _updateNotifications(bool enabled) async {
    DecoNews.of(context).setSubscription(enabled);
  }

  /// Checks is RTL enabled
  Future<void> _isRTLEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _rtlEnabled = prefs.getBool('isRTLEnabled');
      if (_rtlEnabled == null) {
        _rtlEnabled =  Config.defaultLocale == 'ar';
      }
    });
  }

  /// Enables or disables right to left locale support
  Future<void> _updateRTL(bool enabled) async {
    DecoNews.of(context).setRTLSettings(enabled);
  }
}
