import 'package:flutter/material.dart';
import '../helpers/helpers.dart';
import '../helpers/wordpress.dart';
import '../models/post_model.dart';
import '../deco_news_icons.dart';

class News extends StatefulWidget {
  final PostModel post;
  final bool horizontal;
  final VoidCallback onTap;

  News(this.post, {this.horizontal = true, this.onTap});

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return widget.horizontal ? _getHorizontalLayout() : _getVerticalLayout();
  }

  /// Builds widget horizontal layout
  Widget _getHorizontalLayout() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(3),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 5,
            offset: Offset(0, 0),
          ),
        ],
        color: isDark ? Colors.black : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: this.widget.onTap,
          borderRadius: BorderRadius.all(
            Radius.circular(3),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _getImage(),
                    _getCategory(),
                  ],
                ),
                Expanded(
                  child: Container(
                    height: 120,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: _getTitle(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _getDate(),
                            _getBookmark(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds widget horizontal layout
  Widget _getVerticalLayout() {
    return Container(
      height: 120.0,
      margin: EdgeInsets.only(bottom: 10),
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
          onTap: this.widget.onTap,
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                  // _getImage(width: double.infinity),
                  Container(width: double.infinity),
                  _getCategory(),
                ],
              ),
              Expanded(
                child: Container(
                  height: 120.0,
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _getTitle(),
                      _getDate(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns widget title
  Widget _getTitle() {
    return Text(
      this.widget.post.title,
      style: TextStyle(
        fontSize: 18,
        color: isDark ? Colors.white : Color(0xff1B1E28),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Returns category name
  Widget _getCategory() {
    return Container(
      width: 120,
      padding: EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// Returns widget date
  Widget _getDate() {
    return Row(
      children: <Widget>[
        Icon(
          DecoNewsIcons.date,
          // color: Color(0xffCCCBDA),
          size: 20,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
          child: Text(
            localizedDate(context, this.widget.post.date),
            style: TextStyle(
              // color: Color(0xff7F7E96),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Returns widget image
  Widget _getImage({double width: 120.0}) {
    return Hero(
      tag: 'news-image-' + this.widget.post.id.toString(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: FadeInImage(
          placeholder: AssetImage('images/image_placeholder.png'),
          image: this.widget.post.image,
          width: width,
          height: 120.0,
          fit: BoxFit.cover,
        ),
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
