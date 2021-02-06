import 'package:flutter/material.dart';
import 'dart:async';

class DecoScroll extends StatefulWidget {
  final int id;
  final ImageProvider image;
  final double height;
  final List<Widget> widgets;
  final AppBar appBar;
  final double padding;
  final double contentOffset;

  DecoScroll(this.id, this.image, this.height, this.widgets,
      {this.appBar, this.padding = 0.0, this.contentOffset = 0.0});

  @override
  _DecoScrollState createState() => _DecoScrollState();
}

class _DecoScrollState extends State<DecoScroll> {
  ScrollController scrollController;
  double offset = 0.0;
  double top;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        Container(
          height: (this.widget.height - offset).clamp(0.0, this.widget.height),
          child: Hero(
              tag: 'news-image-' + this.widget.id.toString(),
              child: Image(
                image: this.widget.image,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              )),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: EdgeInsets.only(top: top),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: ListView(
              padding: EdgeInsets.only(
                  top: this.widget.height - this.widget.contentOffset,
                  left: this.widget.padding,
                  right: this.widget.padding,
              ),
              controller: scrollController,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: this.widget.widgets)
              ],
            ),
          ),
        ),
        this.widget.appBar == null
            ? Container()
            : Positioned(
                top: 0.0 - offset * 0.2,
                left: 0.0,
                right: 0.0,
                child: this.widget.appBar)
      ],
    );
  }

  void updateOffset() {
    setState(() {
      offset = scrollController.offset;
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(updateOffset);

    top = 1000;
    timer = new Timer(const Duration(milliseconds: 50), () {
      setState(() {
        top = 0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(updateOffset);
    timer.cancel();
  }
}
