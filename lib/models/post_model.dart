import 'package:flutter/material.dart';
import 'category_model.dart';
import 'package:html_unescape/html_unescape.dart';

class PostModel {
  final CategoryModel category;
  final int id;
  final String title;
  final String body;
  final ImageProvider image;
  final String date;
  final String link;
  bool bookmarked;

  PostModel(
    this.id,
    this.category,
    this.title,
    this.body,
    this.image,
    this.date,
    this.link,
    this.bookmarked
  );

  factory PostModel.fromJson(Map<String, dynamic> json, CategoryModel category, { List bookmarks = const [] }) {
    int id = int.parse(json['id'].toString());

    return PostModel(
      id,
      category,
      _getTitle(json['title']['rendered']),
      json['content']['rendered'],
      _getImage(json),
      json['date'],
      Uri.decodeFull(json['link'].toString()),
      bookmarks.indexOf(id) >= 0
    );
  }

  /// Unescape title
  static String _getTitle(String title) {
    var unescape = new HtmlUnescape();
    return unescape.convert(title);
  }

  /// Returns post image
  static ImageProvider _getImage(json) {
    var image;
    if (json['_embedded'] != null && json['_embedded'].containsKey('wp:featuredmedia')) {
      var firstImage = json['_embedded']['wp:featuredmedia'][0];

      if (!firstImage.containsKey('code')) {
        var sizes = firstImage['media_details']['sizes'];

        sizes.forEach((index, value) {
          if (int.parse(value['width'].toString()) < 1200) {
            image = NetworkImage(value['source_url']);
          }
        });
      }
    }

    if (image == null) {
      image = AssetImage('images/image_placeholder.png');
    }

    return image;
  }
}
