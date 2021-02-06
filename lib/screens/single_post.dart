import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share/share.dart';
import '../helpers/deco_localizations.dart';
import '../helpers/helpers.dart';
import '../helpers/wordpress.dart';
import '../widgets/deco_scroll.dart';
import '../widgets/news.dart';
import '../models/post_model.dart';
import '../deco_news_icons.dart';
import 'comments_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SinglePost extends StatefulWidget {
  final PostModel post;
  final bool showAppBar;

  SinglePost(this.post, {this.showAppBar = true});

  @override
  _SinglePostState createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  bool isLoading = true;
  List<PostModel> posts = [];

  @override
  void initState() {
    super.initState();

    /// load posts
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double deviceWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    int divider = 1;

    if (orientation == Orientation.landscape) {
      divider = 2;
    }

    double size = deviceWidth / divider;

    return Padding(
      padding: adPadding(context: context),
      child: Scaffold(
        body: DecoScroll(
          widget.post.id,
          widget.post.image,
          size,
          [_content(context)],
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B1E28).withOpacity(0.25),
            elevation: 0.0,
            iconTheme: IconThemeData(color: Colors.white),

            /// share button
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Share.share(
                      this.widget.post.title + ' ' + this.widget.post.link);
                },
                child: Icon(Icons.share, color: Colors.white),
              )
            ],
          ),
          padding: 10.0,
          contentOffset: 30.0,
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            width: double.infinity,
            height: 55.0,
            margin: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 10.0),
            child: RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CommentsScreen(this.widget.post.id),
              )),
              padding: EdgeInsets.all(0),
              color: isDark ? Colors.white : Color(0xFF1B1E28),
              textColor: isDark ? Color(0xFF1B1E28) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Text(DecoLocalizations.of(context)
                  .localizedString("single_post_view_all_comments")),
            ),
          ),
        ),
      ),
    );
  }

  _content(context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double deviceWidth = MediaQuery.of(context).size.width;

    return InteractiveViewer(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            decoration: BoxDecoration(
                color: isDark ? Color(0xFF1B1E28) : Colors.white,
                borderRadius: BorderRadius.circular(3.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 5.0,
                    offset: Offset(0.0, 0.0),
                  )
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Color(0xffCB0000),
                          borderRadius: BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                        child: Text(
                          this.widget.post.category.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      /// bookmark button
                      InkWell(
                        onTap: () {
                          setState(() {
                            this.widget.post.bookmarked =
                                !this.widget.post.bookmarked;
                            WordPress.updateBookmarks(this.widget.post.id);
                          });
                        },
                        child: Icon(
                          DecoNewsIcons.add_to_bookmark,
                          color: this.widget.post.bookmarked
                              ? Color(0xFFdc3446)
                              : Color(0xffCCCBDA),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    widget.post.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1B1E28),
                      fontSize: 20.0,
                    ),
                  ),
                ),

                deviceWidth < 360 ? _getSmallDate() : _getDate(),

                /// post content (HTML)
                Html(
                  data: this.widget.post.body,
                  style: {
                    "p": Style(
                        fontSize: FontSize(16),
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.normal,
                        // height: 16.0 / 14.0,
                        textAlign: TextAlign.start),
                    "img": Style(
                      width: double.infinity,
                    )
                  },
                  onLinkTap: (url) async {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ],
            ),
          ),
          if (posts.length > 0)
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        DecoLocalizations.of(context)
                            .localizedString("single_post_related_posts"),
                        style: TextStyle(
                            fontSize: 18.0,
                            color: isDark ? Colors.white : Color(0xFF1B1E28)),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: posts.length,

                  /// return news widget
                  itemBuilder: (BuildContext context, int index) => News(
                    posts[index],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SinglePost(posts[index]),
                    )),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _getSmallDate() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                DecoNewsIcons.date,
                color: Color(0xFFCCCBDA),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                child: Text(
                  localizedDate(context, widget.post.date),
                  style: TextStyle(
                    color: Color(0xFF7F7E96),
                  ),
                ),
              ),
            ],
          ),
          FlatButton(
            padding: EdgeInsets.only(left: 0),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CommentsScreen(this.widget.post.id),
            )),
            child: Row(
              children: <Widget>[
                Icon(
                  DecoNewsIcons.comments,
                  color: Color(0xFFCCCBDA),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    DecoLocalizations.of(context).localizedString("comments"),
                    style: TextStyle(
                      color: Color(0xFF7F7E96),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getDate() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            DecoNewsIcons.date,
            color: Color(0xFFCCCBDA),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 15.0, 0.0),
            child: Text(
              localizedDate(context, widget.post.date),
              style: TextStyle(
                color: Color(0xFF7F7E96),
              ),
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CommentsScreen(this.widget.post.id),
            )),
            child: Row(
              children: <Widget>[
                Icon(
                  DecoNewsIcons.comments,
                  color: Color(0xFFCCCBDA),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    DecoLocalizations.of(context).localizedString("comments"),
                    style: TextStyle(
                      color: Color(0xFF7F7E96),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// load posts
  _loadData({clear = false}) async {
    /// Fetch posts and bookmarks
    var data = await Future.wait([
      WordPress.fetchPosts(
          category: this.widget.post.category.id, exclude: this.widget.post.id),
      WordPress.getBookmarkedPostIDs()
    ]);

    Response response = data[0];
    List bookmarks = data[1];

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          /// append loaded posts to existing list
          (json.decode(response.body) as List)
              .map((data) => posts.add(new PostModel.fromJson(
                  data, this.widget.post.category,
                  bookmarks: bookmarks)))
              .toList();

          /// disable loading animations
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
}
