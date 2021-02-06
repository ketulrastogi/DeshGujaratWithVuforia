import 'package:flutter/material.dart';
import '../helpers/helpers.dart';
import '../helpers/wordpress.dart';
import '../models/post_model.dart';
import '../deco_news_icons.dart';

class SliderNews extends StatefulWidget {
  final PostModel post;
  final VoidCallback onTap;

  SliderNews(this.post, {this.onTap});

  @override
  _SliderNewsState createState() => _SliderNewsState();
}

class _SliderNewsState extends State<SliderNews> {
  bool isDark = false;
  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            // height: 135.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Colors.black.withAlpha(0)),
            child: Hero(
              tag: 'news-image-' + widget.post.id.toString(),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                // child: FadeInImage(
                //   placeholder: AssetImage('images/image_placeholder.png'),
                //   image: this.widget.post.image,
                //   fit: BoxFit.cover,
                // )
                // child: Text(this.widget.post.title),
              ),
            ),
          ),
          Container(
            height: 210.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 5,
                  offset: Offset(0, 0),
                ),
              ],
              color: isDark ? Color(0xFF1B1E28) : Color(0xFFFFFFFF),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(15),
                      // decoration: BoxDecoration(
                      //   borderRadius:
                      //       BorderRadius.vertical(top: Radius.circular(3)),
                      //   gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.black,
                      //       Colors.black.withAlpha(0),
                      //     ],
                      //   ),
                      // ),
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
                          _getBookmark(),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      // decoration: BoxDecoration(
                      //   borderRadius:
                      //       BorderRadius.vertical(bottom: Radius.circular(3)),
                      //   gradient: LinearGradient(
                      //     begin: Alignment.bottomCenter,
                      //     end: Alignment.topCenter,
                      //     colors: [
                      //       Colors.black,
                      //       Color.fromRGBO(0, 0, 0, 0),
                      //     ],
                      //   ),
                      // ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Text(
                                    widget.post.title,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      // color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                DecoNewsIcons.date,
                                // color: Colors.white,
                                size: 20,
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    5.0, 0.0, 15.0, 0.0),
                                child: Text(
                                  localizedDate(context, this.widget.post.date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    // color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns bookmark button
  Widget _getBookmark() {
    return InkWell(
      onTap: () {
        setState(() {
          this.widget.post.bookmarked = !this.widget.post.bookmarked;
          WordPress.updateBookmarks(this.widget.post.id);
        });
      },
      child: Icon(
        DecoNewsIcons.add_to_bookmark,
        color:
            this.widget.post.bookmarked ? Color(0xFFdc3446) : Color(0xffCCCBDA),
        size: 20,
      ),
    );
  }
}
