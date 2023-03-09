import 'package:flutter/material.dart';

class OutlinedBtn extends StatelessWidget {
  final Function()? onPressed;
  final Widget child;
  const OutlinedBtn({required this.onPressed, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    Set<MaterialState>? state = {MaterialState.disabled};
    Theme.of(context).outlinedButtonTheme.style?.side?.resolve(state);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
          side:
              onPressed == null ? const BorderSide(color: Colors.grey) : null),
      child: child,
    );
  }
}
