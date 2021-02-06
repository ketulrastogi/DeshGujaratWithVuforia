import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import '../helpers/helpers.dart';
import '../models/comment_model.dart';

class Comment extends StatelessWidget {
  final CommentModel comment;

  Comment(this.comment);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
        color: isDark ? Color(0xFF1B1E28) : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              child: CircleAvatar(
                backgroundImage: comment.authorAvatar,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                    height: 30,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            child: Text(
                              comment.authorName,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Color(0xFF1B1E28),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            padding: EdgeInsets.only(right: 10),
                          ),
                        ),
                        Text(
                          localizedDate(context, comment.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F7E96),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                    child: Html(
                      data: comment.content,
                      style: {
                        "p": Style(
                          fontSize: FontSize(14),
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.normal,
                          // height: 16.0 / 14.0,
                          textAlign: TextAlign.start
                        ),
                      }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
