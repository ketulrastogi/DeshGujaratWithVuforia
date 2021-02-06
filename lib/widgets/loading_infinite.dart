import 'package:flutter/material.dart';

class LoadingInfinite extends StatelessWidget {
  final bool canLoadMore;

  LoadingInfinite(this.canLoadMore);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return canLoadMore ? Container(
      height: 60,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white : Color(0xFF1B1E28))
          )
        ),
      )
    ) : Container(height: canLoadMore ? 60 : 0);
  }
}