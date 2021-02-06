import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../helpers/deco_localizations.dart';
import '../helpers/wordpress.dart';
import '../helpers/helpers.dart';
import '../widgets/deco_appbar.dart';
import '../widgets/input.dart';

class CommentsAddScreen extends StatefulWidget {
  final int postID;

  CommentsAddScreen(this.postID);

  @override
  _CommentsAddScreenState createState() => _CommentsAddScreenState();
}

class _CommentsAddScreenState extends State<CommentsAddScreen> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'author_email': null,
    'author_name': null,
    'content': null,
    'post': null,
  };
  bool showEmailError = false;
  bool showNameError = false;
  bool showContentError = false;

  @override
  void initState() {
    super.initState();

    _formData['post'] = this.widget.postID.toString();

    _emailFocus.addListener(() {
      setState(() {
        showEmailError = false;
      });
    });

    _nameFocus.addListener(() {
      setState(() {
        showNameError = false;
      });
    });

    _contentFocus.addListener(() {
      setState(() {
        showContentError = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _emailFocus.dispose();
    _nameFocus.dispose();
    _contentFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: adPadding(context: context),
      child: Scaffold(
        appBar: DecoNewsAppBar(),
        body: GestureDetector(

          // close keyboard on outside input tap
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },

          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[

                  Input(
                    hintText: DecoLocalizations.of(context).localizedString("add_comment_name_hint"),
                    margin: EdgeInsets.only(bottom: 10),
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    showErrorIcon: showNameError,
                    onFieldSubmitted: (term) {
                      _nameFocus.unfocus();
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                    onSaved: (String value) {
                      _formData['author_name'] = value;
                    },
                  ),

                  Input(
                    hintText: DecoLocalizations.of(context).localizedString("add_comment_email_hint"),
                    margin: EdgeInsets.only(bottom: 10),
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    showErrorIcon: showEmailError,
                    onFieldSubmitted: (term) {
                      _emailFocus.unfocus();
                      FocusScope.of(context).requestFocus(_contentFocus);
                    },
                    onSaved: (String value) {
                      _formData['author_email'] = value;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),

                  Input(
                    hintText: DecoLocalizations.of(context).localizedString("add_comment_comment_hint"),
                    maxLines: 8,
                    focusNode: _contentFocus,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    showErrorIcon: showContentError,
                    onFieldSubmitted: (term) {
                      _contentFocus.unfocus();
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    onSaved: (String value) {
                      _formData['content'] = value;
                    },
                  ),
                ],
              ),
            )
          ),
        ),

        bottomNavigationBar: SafeArea(
          child: Container(
            width: double.infinity,
            height: 55.0,
            margin: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 10.0),
            child: RaisedButton(
              onPressed: () {

                // submit form
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _addComment(context, _formData);
                }

              },
              padding: EdgeInsets.all(0),
              color: isDark ? Colors.white : Color(0xFF1B1E28),
              textColor: isDark ? Color(0xFF1B1E28) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)),
              child: Text(DecoLocalizations.of(context).localizedString("add_comment_post")),
            ),
          ),
        ),
      ),
    );
  }

  /// Posts comment data to server
  Future<void> _addComment(context, data) async {
    bool isValid = true;

    /// lets do basic validation
    if (data['author_email'].isEmpty) {
      setState(() {
        showEmailError = true;
      });

      isValid = false;
    }

    if (data['author_name'].isEmpty) {
      setState(() {
        showNameError = true;
      });

      isValid = false;
    }

    if (data['content'].isEmpty) {
      setState(() {
        showContentError = true;
      });

      isValid = false;
    }

    if (isValid) {
      /// show loading message
      showLoadingDialog(context);

      /// send request to server
      Response response = await WordPress.addComment(data);

      /// close loading
      Navigator.of(context, rootNavigator: true).pop('dialog');

      /// check what request successful
      if (response.statusCode == 201) {
        _formKey.currentState.reset();
        Navigator.of(context).pop();
      } else if (response.statusCode == 400) {
        final decodedResponse = json.decode(response.body);
        final error = decodedResponse['data']['params'];
        final errorMessage = error[error.keys.first];

        showErrorDialog(
          context,
          'An error occurred',
          errorMessage
        );
      } else {
        showErrorDialog(
          context,
          'An error occurred',
          'Please try again later'
        );
      }
    }
  }
}
