import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../helpers/helpers.dart';
import '../helpers/wordpress.dart';
import '../models/category_model.dart';
import '../widgets/category.dart';
import '../widgets/loading.dart';
import '../widgets/deco_appbar.dart';
import '../widgets/deco_news_drawer.dart';
import 'single_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool isLoading = true;
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();

    /// load list of categories
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: adPadding(context: context),
      child: Scaffold(
        appBar: DecoNewsAppBar(),
        drawer: DecoNewsDrawer(),
        body: _buildBody()
      ),
    );
  }

  _buildBody() {

    /// show loading message
    if (isLoading) {
      return Loading();
    }

    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 2;

    if (deviceWidth > 1100) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }

    /// grid view of categories
    return GridView.count(
      crossAxisCount: widgetsInRow,
      children: categories.asMap().entries.map((category) => Category(
        category.value,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SingleCategoryScreen(category.value),
          )
        ),
        index: category.key + 1,
      )).toList(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: EdgeInsets.all(10),
    );
  }

  /// load list of categories
  _loadData() async {
    Response response = await WordPress.fetchCategories();

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {

          /// create category models from loaded categories
          (json.decode(response.body) as List)
            .map((data) => categories.add(new CategoryModel.fromJson(data)))
            .toList();

          /// disable loading animations
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
}
