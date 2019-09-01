import 'package:flutter/material.dart';

Future<void> errorDialog(
    {BuildContext context, String errorTitle, String errorMessage}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(errorTitle),
      content: Text(errorMessage),
      actions: <Widget>[
        RaisedButton(
          color: Theme.of(context).accentColor,
          child: Text(
            "Dismiss",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    ),
  );
}
