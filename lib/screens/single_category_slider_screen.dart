import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import '../helpers/deco_localizations.dart';
import '../helpers/wordpress.dart';
import '../models/category_model.dart';
import '../models/post_model.dart';
import '../widgets/slider_news.dart';
import '../widgets/news.dart';
import '../widgets/loading.dart';
import '../widgets/loading_infinite.dart';
import '../widgets/carousel.dart';
import 'single_post.dart';

class SingleCategorySliderScreen extends StatefulWidget {
  final CategoryModel category;

  SingleCategorySliderScreen(this.category);

  @override
  _SingleCategorySliderScreenState createState() =>
      _SingleCategorySliderScreenState();
}

class _SingleCategorySliderScreenState extends State<SingleCategorySliderScreen>
    with AutomaticKeepAliveClientMixin<SingleCategorySliderScreen> {
  bool isLoading = true;
  bool loadingMore = false;
  bool canLoadMore = true;
  int page = 1;
  List<PostModel> posts = [];
  List<PostModel> featured = [];

  void initState() {
    super.initState();

    /// load posts
    _loadData();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 2;

    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }

    double aspectRatio =
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 200;

    /// show loading message
    if (isLoading) {
      return Loading();
    }

    /// add pull to refresh
    return RefreshIndicator(
      onRefresh: () => _loadData(clear: true),
      color: Color(0xFF1B1E28),
      child: NotificationListener(
        onNotification: (ScrollNotification scroll) {
          bool shouldLoadMore =
              scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                  !this.loadingMore &&
                  this.canLoadMore;

          if (shouldLoadMore) {
            _loadData();
            return true;
          }

          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (this.featured.length > 0)
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        DecoLocalizations.of(context).localizedString(
                            "single_category_slider_screen_featured_news"),
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF1B1E28)),
                      ),
                    ),
                  ],
                ),

              /// Carousel widget
              if (featured.length > 0)
                Container(
                  height: 184,
                  child: Carousel(
                    showIndicator: false,
                    pages: featured
                        .map((PostModel post) => SliderNews(
                              post,
                              onTap: () {
                                int index = featured.indexOf(post);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      SinglePost(featured[index]),
                                ));
                              },
                            ))
                        .toList(),
                  ),
                ),

              Row(
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 0.0, 10.0),
                    child: Text(
                      this.widget.category.name,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Color(0xFF1B1E28)),
                    ),
                  ),
                ],
              ),

              GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: posts.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widgetsInRow,
                  crossAxisSpacing: 10,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (BuildContext context, int index) => News(
                  posts[index],
                  horizontal: false,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SinglePost(posts[index]),
                    ));
                  },
                ),
              ),

              LoadingInfinite(canLoadMore),
            ],
          ),
        ),
      ),
    );
  }

  /// load posts
  _loadData({clear = false}) async {
    if (page > 1) {
      setState(() {
        loadingMore = true;
      });
    }

    if (clear) {
      page = 1;
    }

    /// Fetch posts and bookmarks
    var data = await Future.wait([
      WordPress.fetchPosts(category: this.widget.category.id, page: page),
      WordPress.getBookmarkedPostIDs()
    ]);

    Response response = data[0];
    List bookmarks = data[1];

    if (response.statusCode == 200) {
      int totalPosts = int.parse(response.headers['x-wp-total'].toString());

      if (mounted) {
        setState(() {
          /// on refreshing page need to clean up
          if (clear) {
            posts.clear();
          }

          /// create post models from loaded posts
          List<PostModel> loadedPosts = (json.decode(response.body) as List)
              .map((data) => new PostModel.fromJson(data, this.widget.category,
                  bookmarks: bookmarks))
              .toList();

          /// update featured posts
          if (page == 1) {
            int max = loadedPosts.length;
            if (max > 3) {
              max = 3;
            }

            featured = loadedPosts.sublist(0, max);
            loadedPosts = loadedPosts.sublist(max);
          }

          /// append loaded posts to existing list
          posts = List.from(posts)..addAll(loadedPosts);

          /// disable loading animations
          isLoading = false;
          loadingMore = false;

          /// allow loading more if category have more posts then loaded
          canLoadMore = (posts.length + featured.length) < totalPosts;

          /// increase page count
          page += 1;
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
}
