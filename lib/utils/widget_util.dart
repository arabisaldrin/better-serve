import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(BuildContext context, Widget child,
    [ToastGravity? gravity = ToastGravity.TOP,
    Color? color,
    int duration = 1500]) {
  FToast().init(context).showToast(
      gravity: gravity,
      toastDuration: Duration(milliseconds: duration),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(20),
        color: color,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: child,
        ),
      ));
}

showLoading(context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Please wait..")
                  ],
                ),
              ],
            ),
          ),
        );
      });
}
