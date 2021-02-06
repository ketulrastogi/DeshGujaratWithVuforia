import 'package:deshgujarat/screens/tweets_screen.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';
import '../deco_news_icons.dart';
import '../main.dart';
import '../helpers/deco_localizations.dart';

class DrawerItem {
  final String title;
  final Function page;
  final IconData icon;

  DrawerItem(this.title, this.icon, this.page);
}

class DecoNewsDrawer extends StatelessWidget {
  /// This is the list of items that will be shown in drawer
  static final List<DrawerItem> drawerItems = [
    DrawerItem('home', DecoNewsIcons.home_icon, () => HomeScreen()),
    DrawerItem('Tweets', DecoNewsIcons.twitter, () => TweetsScreen()),
    DrawerItem(
        'categories', DecoNewsIcons.categories_icon, () => CategoriesScreen()),
    DrawerItem(
        'bookmarks', DecoNewsIcons.add_to_bookmark, () => BookmarksScreen()),
    DrawerItem('about_app', DecoNewsIcons.about_icon, () => AboutScreen()),
    DrawerItem('settings', Icons.settings, () => SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    int selectedIndex = DecoNews.of(context).getSelected();

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Color(0xFF1B1E28)),
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            /// Header
            Container(
              padding: EdgeInsets.only(top: 60.0, bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
                    width: 60.0,
                    child: Image.asset('images/deco_logo.png'),
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        Config.appTitle,
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      Text(
                        'News App',
                        style:
                            TextStyle(color: Color(0xFF7F7E96), fontSize: 14.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Drawer items
            Expanded(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: drawerItems.map((DrawerItem item) {
                    int index = drawerItems.indexOf(item);

                    return Container(
                      height: 50.0,
                      margin:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 50.0, 0.0),
                      decoration: BoxDecoration(
                        color: index == selectedIndex
                            ? Color(0xFF282C39)
                            : Color(0x00282C39),
                        borderRadius:
                            BorderRadius.horizontal(right: Radius.circular(25)),
                      ),
                      child: ListTile(
                        leading: Icon(
                          item.icon,
                          size: 20.0,
                          color: index == selectedIndex
                              ? Colors.white
                              : Color(0xFF7F7E96),
                        ),
                        title: Text(
                          DecoLocalizations.of(context)
                              .localizedString(item.title),
                          style: TextStyle(
                            color: index == selectedIndex
                                ? Colors.white
                                : Color(0xFF7F7E96),
                            fontSize: 16.0,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);

                          DecoNews.of(context).setSelected(index);

                          Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, anim1, anim2) =>
                                    item.page(),
                                transitionsBuilder:
                                    (context, anim1, anim2, child) =>
                                        FadeTransition(
                                            opacity: anim1, child: child),
                                transitionDuration: Duration(milliseconds: 200),
                              ));
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            /// Footer
            Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 20.0, 0.0, 0.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        /// TODO define your tap action here
                      },
                      child: Icon(
                        DecoNewsIcons.instagram,
                        color: Color(0xFF7F7E96),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 20.0, 0.0, 0.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        /// TODO define your tap action here
                      },
                      child: Icon(
                        DecoNewsIcons.facebook,
                        color: Color(0xFF7F7E96),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        15.0, 20.0, 0.0, 0.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        /// TODO define your tap action here
                      },
                      child: Icon(
                        DecoNewsIcons.twitter,
                        color: Color(0xFF7F7E96),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        15.0, 20.0, 0.0, 0.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        /// TODO define your tap action here
                      },
                      child: Icon(
                        DecoNewsIcons.youtube,
                        color: Color(0xFF7F7E96),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
