import 'package:flutter/material.dart';

class CommentModel {
  final int id;
  final String authorName;
  final ImageProvider authorAvatar;
  final String content;
  final String date;

  CommentModel({
    this.id,
    this.authorName,
    this.authorAvatar,
    this.content,
    this.date,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: int.parse(json['id'].toString()),
      authorName: json['author_name'],
      authorAvatar: _getImage(json['author_avatar_urls']),
      content: json['content']['rendered'],
      date: json['date'].toString(),
    );
  }

  /// Returns author image
  static ImageProvider _getImage(input) {
    var image;

    if (input.length > 0) {
      image = NetworkImage(input[input.keys.last]);
    }

    if (image == null) {
      image = AssetImage('images/image_placeholder.png');
    }

    return image;
  }
}
