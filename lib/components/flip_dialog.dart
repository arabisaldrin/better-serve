import 'dart:math';

import 'package:flutter/material.dart';

class FlipDialog extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    void Function() flip,
  ) frontBuilder;
  final Widget Function(
    BuildContext context,
    void Function() flip,
  ) backBuilder;
  final int flipDuration;
  const FlipDialog(
      {Key? key,
      required this.frontBuilder,
      required this.backBuilder,
      this.flipDuration = 300})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FlipDialogState();
}

class _FlipDialogState extends State<FlipDialog> {
  bool isBack = false;
  double angle = 0;

  void _flip() {
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SingleChildScrollView(
          child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: angle),
              duration: Duration(milliseconds: widget.flipDuration),
              builder: (BuildContext context, double val, __) {
                if (val >= (pi / 2)) {
                  isBack = false;
                } else {
                  isBack = true;
                }
                return (Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(val),
                    child: SizedBox(
                      child: isBack
                          ? widget.frontBuilder(context, _flip)
                          : WillPopScope(
                              onWillPop: () {
                                _flip();
                                return Future.value(false);
                              },
                              child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: widget.backBuilder(context, _flip)),
                            ),
                    )));
              }),
        ),
      ],
    );
  }
}
