import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../helpers/helpers.dart';
import '../helpers/deco_localizations.dart';
import '../helpers/wordpress.dart';
import '../models/category_model.dart';
import '../models/post_model.dart';
import '../widgets/news.dart';
import '../widgets/loading.dart';
import '../widgets/loading_infinite.dart';
import '../widgets/deco_appbar.dart';
import 'single_post.dart';

class SingleCategoryScreen extends StatefulWidget {
  final CategoryModel category;

  SingleCategoryScreen(this.category);

  @override
  _SingleCategoryScreenState createState() => _SingleCategoryScreenState();
}

class _SingleCategoryScreenState extends State<SingleCategoryScreen> {
  bool isLoading = true;
  bool loadingMore = false;
  bool canLoadMore = true;
  int page = 1;
  List<PostModel> posts = [];

  void initState() {
    super.initState();

    /// load posts
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: adPadding(context: context),
      child: Scaffold(
        appBar: DecoNewsAppBar(),
        body: _buildBody()
      ),
    );
  }

  Widget _buildBody() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                    child: Text(
                      DecoLocalizations.of(context).localizedString("single_category_recent_news"),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: isDark ? Colors.white : Color(0xFF1B1E28)
                      ),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: posts.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  /// loading at bottom of the list
                  if (index == posts.length) {
                    return LoadingInfinite(canLoadMore);
                  }

                  /// return news widget
                  return News(
                    posts[index],
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SinglePost(posts[index]),
                      ));
                    },
                  );
                }
              ),
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

          /// append loaded posts to existing list
          (json.decode(response.body) as List)
              .map((data) => posts.add(new PostModel.fromJson(
                  data, this.widget.category,
                  bookmarks: bookmarks)))
              .toList();

          /// disable loading animations
          isLoading = false;
          loadingMore = false;

          /// allow loading more if category have more posts then loaded
          canLoadMore = posts.length < totalPosts;

          /// increase page count
          page += 1;
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
}
