import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final EdgeInsets margin;
  final String hintText;
  final int maxLines;
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final Function onFieldSubmitted;
  final Function validator;
  final Function onSaved;
  final bool showErrorIcon;

  Input(
      {this.margin,
      this.hintText,
      this.maxLines,
      this.textInputAction,
      this.focusNode,
      this.keyboardType,
      this.textCapitalization = TextCapitalization.none,
      this.onFieldSubmitted,
      this.validator,
      this.onSaved,
      this.showErrorIcon = false});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1B1E28) : Colors.white,
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
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: this.hintText,
          contentPadding: EdgeInsets.all(15),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: this.showErrorIcon
              ? Icon(
                  Icons.error,
                  color: Color(0xFFf04141),
                )
              : null,
        ),
        style:
            TextStyle(color: Color(0xFF7F7E96), fontSize: 14, height: 16 / 14),
        maxLines: maxLines,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        cursorColor: Color(0xFF7F7E96),
      ),
    );
  }
}
