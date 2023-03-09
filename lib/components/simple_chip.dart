import 'package:flutter/material.dart';

class SimpleChip extends StatelessWidget {
  final String text;
  final bool selected;
  final Function()? onTap;
  final Color? color;
  final EdgeInsets? padding;
  const SimpleChip(
      {Key? key,
      required this.text,
      required this.selected,
      this.color,
      this.padding,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 60),
              alignment: Alignment.center,
              padding: padding ?? const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border:
                      Border.all(color: color ?? Colors.blueAccent, width: 1),
                  borderRadius: BorderRadius.circular(5),
                  color: selected ? color : null),
              child: Row(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        color: selected ? Colors.white : color, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
