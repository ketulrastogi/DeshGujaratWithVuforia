import 'dart:convert';
import 'package:deshgujarat/helpers/deco_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../helpers/wordpress.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';
import '../widgets/loading.dart';
import '../screens/single_post.dart';
import '../widgets/search_results.dart';
import '../widgets/search_error.dart';

class SearchDemoSearchDelegate extends SearchDelegate<int> {
  List<PostModel> _data = List();

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: DecoLocalizations.of(context).localizedString("search_back"),
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: _getResults(context, query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SearchResults(_data, _presentPost);
        } else if (snapshot.hasError) {
          return SearchError();
        }

        // By default, show a loading spinner.
        return Loading();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResults(_data, _presentPost);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty ? Container() : IconButton(
        tooltip: DecoLocalizations.of(context).localizedString("search_clear"),
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1B1E28) : Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Color(0xFFb3bbbf)),
      primaryColorBrightness: Theme.of(context).brightness,
      primaryTextTheme: theme.textTheme,
    );
  }

  /// get search results
  Future<List<PostModel>> _getResults(context, String query) async {
    var searchResults = await WordPress.search(query);
    var searchResultsData = json.decode(searchResults.body);
    int searchResultsCount = searchResultsData.length;

    if (searchResultsCount > 0) {
      // generate list of category ids
      Set categoryIDs = new Set();
      searchResultsData.forEach((post) {
        categoryIDs.add(post['categories'][0]);
      });

      // get categories and bookmark data
      var data = await Future.wait([
        WordPress.fetchCategory(categoryIDs.join(',')),
        WordPress.getBookmarkedPostIDs()
      ]);

      Response categoriesResponse = data[0];
      List bookmarks = data[1];

      // create list of categories
      List<CategoryModel> categories = (json.decode(categoriesResponse.body) as List)
        .map((category) => CategoryModel.fromJson(category))
        .toList();

      // create list of posts
      _data = (searchResultsData as List).map((post) {
        CategoryModel category = categories.firstWhere(
            (cat) => cat.id == post['categories'][0]
        );

        return PostModel.fromJson(post, category, bookmarks: bookmarks);
      }).toList();
    } else {
      _data = [];
    }

    return _data;
  }

  /// open post screen
  _presentPost(BuildContext context, PostModel post) {
    this.close(context, post.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SinglePost(post)
      )
    );
  }
}

