import 'package:html_unescape/html_unescape.dart';

class CategoryModel {
  final int count;
  final String description;
  final int id;
  final String link;
  final String name;
  final int parent;

  CategoryModel(
    this.count,
    this.description,
    this.id,
    this.link,
    this.name,
    this.parent
  );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      int.parse(json['count'].toString()),
      json['description'],
      int.parse(json['id'].toString()),
      json['link'],
      _getTitle(json['name']),
      int.parse(json['parent'].toString()),
    );
  }

  /// Unescape title
  static String _getTitle(String title) {
    var unescape = new HtmlUnescape();
    return unescape.convert(title);
  }
}
