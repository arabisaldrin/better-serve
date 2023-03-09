import 'package:flutter/material.dart';

enum DialogType { info, error, warning, question }

class CustomDialog extends StatelessWidget {
  final String title, content, positiveBtnText, negativeBtnText;
  final GestureTapCallback? positiveBtnPressed;
  final DialogType type;
  final Widget? icon;

  const CustomDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.positiveBtnText,
      required this.negativeBtnText,
      required this.positiveBtnPressed,
      required this.type,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // Bottom rectangular box
              margin: const EdgeInsets.only(
                  top: 40), // to push the box half way below circle

              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 50, left: 20, right: 20), // spacing inside the box
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                      ButtonBar(
                        buttonMinWidth: 100,
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                            child: Text(negativeBtnText),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            onPressed: positiveBtnPressed,
                            child: Text(positiveBtnText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        icon ?? getAvatar(DialogType.warning, context)
      ],
    );
  }

  Widget getAvatar(DialogType type, BuildContext context) {
    switch (type) {
      case DialogType.info:
        return const CircleAvatar(
          maxRadius: 40.0,
          backgroundColor: Colors.blueAccent,
          child: Icon(
            Icons.message,
            size: 30,
            color: Colors.white,
          ),
        );
      case DialogType.error:
        return const CircleAvatar(
          maxRadius: 40.0,
          backgroundColor: Colors.redAccent,
          child: Icon(
            Icons.error_outline,
            size: 30,
            color: Colors.white,
          ),
        );
      case DialogType.warning:
        return CircleAvatar(
          maxRadius: 40.0,
          backgroundColor: Colors.yellow.shade700,
          child: const Icon(
            Icons.warning,
            size: 30,
            color: Colors.white,
          ),
        );
      case DialogType.question:
        return const CircleAvatar(
          maxRadius: 40.0,
          backgroundColor: Colors.green,
          child: Icon(
            Icons.question_mark,
            size: 30,
            color: Colors.white,
          ),
        );
    }
  }
}
