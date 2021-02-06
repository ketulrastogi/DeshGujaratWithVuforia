import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/deco_localizations.dart';
import '../models/category_model.dart';

class Category extends StatefulWidget {
  final CategoryModel cat;
  final VoidCallback onTap;
  final int index;

  Category(this.cat, { this.onTap, this.index });

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  String _backgroundImage;

  initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      String backgroundImage = await getImage();

      if (backgroundImage != null) {
        setState(() => _backgroundImage = backgroundImage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 5,
              offset: Offset(0, 0),
            )
          ],
          image: _backgroundImage != null ? DecorationImage(
            image: AssetImage(_backgroundImage),
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
            fit: BoxFit.cover,
          ) :null,
          borderRadius: BorderRadius.all(Radius.circular(3))
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: _backgroundImage != null ? Colors.transparent : isDark ? Color(0xFF1B1E28) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.cat.name,
                  style: TextStyle(
                    color: (isDark || _backgroundImage != null) ? Colors.white : Color(0xFF1B1E28),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  widget.cat.count.toString() + DecoLocalizations.of(context).localizedString("category_posts_num"),
                  style: TextStyle(
                    color: _backgroundImage != null ? Colors.white : Color(0xFF7F7E96),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getImage() async {
    if (widget.index == null) {
      return null;
    }

    String image = widget.index > 9 ? widget.index.toString() : '0${widget.index}';
    String path = 'images/categories/category-';
    String jpg = path + image + '.jpg';

    try {
      await rootBundle.load(jpg);
      return jpg;
    } catch(exception) {}

    String jpeg = path + image + '.jpeg';
    try {
      await rootBundle.load(jpeg);
      return jpeg;
    } catch(exception) {}

    String png = path + image + '.png';
    try {
      await rootBundle.load(png);
      return png;
    } catch(exception) {}

    return null;
  }
}
