import 'package:flutter/material.dart';

void showSuccessAlertDialog(BuildContext context, String text) {
  // set up the buttons
  Widget continueButton = TextButton(
    child: Text(
      "Confirm",
      style: TextStyle(
        color: Colors.orange,
      ),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(
      ("name: AMWR2"),
    ),
    actions: [
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
