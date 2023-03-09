import 'package:flutter/material.dart';

class Inverted extends StatelessWidget {
  final Widget child;
  const Inverted({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1, 0, 0, 0, 255, //
          0, -1, 0, 0, 255, //
          0, 0, -1, 0, 255, //
          0, 0, 0, 1, 0, //
        ]),
        child: child);
  }
}
