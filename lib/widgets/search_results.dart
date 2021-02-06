import 'package:flutter/material.dart';
import '../helpers/deco_localizations.dart';
import '../models/post_model.dart';
import 'news.dart';

class SearchResults extends StatelessWidget {
  final List<PostModel> results;
  final Function onTap;

  SearchResults(this.results, this.onTap);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                child: Text(
                  DecoLocalizations.of(context).localizedString("search_results"),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: isDark ? Colors.white : Color(0xFF1B1E28),
                  ),
                ),
              ),
            ],
          ),

          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (BuildContext context, int index) {
              final suggestion = results[index];

              return News(
                suggestion,
                onTap: () => onTap(context, suggestion),
              );
            }
          ),
        ],
      ),
    );
  }
}
