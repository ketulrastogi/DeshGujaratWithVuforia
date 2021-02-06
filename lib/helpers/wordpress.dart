import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class WordPress {

  /// Fetch category by id
  static Future fetchCategory(String categoryID) {
    String url = '${Config.apiEndpoint}/categories?include=$categoryID';
    return http.get(url);
  }

  /// Fetch list of categories
  static Future fetchCategories() {
    String url = '${Config.apiEndpoint}/categories?per_page=100';
    if (Config.excludeCategories.length > 0) {
      url += '&exclude=${Config.excludeCategories.join(',')}';
    }

    return http.get(url);
  }

  /// Fetch post by id
  static Future fetchPost(int postId) {
    String url = '${Config.apiEndpoint}/posts/$postId?_embed';
    return http.get(url);
  }

  /// Fetch list of posts
  static Future fetchPosts({int category, int page, int exclude}) {
    String url = '${Config.apiEndpoint}/posts?_embed&per_page=10';

    if (category != null) {
      url += '&categories=${category.toString()}';
    }

    if (page != null) {
      url += '&page=${page.toString()}';
    }

    if (exclude != null) {
      url += '&exclude=$exclude';
    }

    return http.get(url);
  }

  /// Return list of posts from list of ids
  static Future fetchPostsFromList(List<int> posts) {
    String url = '${Config.apiEndpoint}/posts?_embed&include=${posts.join(',')}';
    return http.get(url);
  }

  /// Fetch list of comments
  static Future fetchComments(int postID, { int page = 1, int perPage = 10}) {
    final String url = '${Config.apiEndpoint}/comments?post=$postID&page=$page&per_page=$perPage';
    return http.get(url);
  }

  /// Add new comment
  static Future addComment(body) {
    final String url = '${Config.apiEndpoint}/comments';
    return http.post(url, body: jsonEncode(body), headers: {
      HttpHeaders.contentTypeHeader: 'application/json'
    });
  }

  /// Returns list of bookmarked post IDs
  static Future<List<int>> getBookmarkedPostIDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storage = (prefs.getString('bookmarks') ?? '');

    if (storage != '') {
      return (json.decode(storage) as List)
        .map((id) => int.parse(id.toString()))
        .toList();
    } else {
      return new List();
    }
  }

  /// Adds or removes post from bookmarks
  static updateBookmarks(postID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var storage = (prefs.getString('bookmarks') ?? '');
    var bookmarks = [];

    if (storage != '') {
      bookmarks = (json.decode(storage) as List)
        .map((id) => int.parse(id.toString()))
        .toList();
    }

    if (bookmarks.indexOf(postID) >= 0) {
      bookmarks.remove(postID);
    } else {
      bookmarks.add(postID);
    }

    await prefs.setString('bookmarks', json.encode(bookmarks));
  }

  /// Removes all post IDs from bookmarks
  static clearBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookmarks', null);
  }

  /// Posts search
  static search(String query) async {
    String url = '${Config.apiEndpoint}/posts?search=$query&_embed';
    return http.get(url);
  }
}
