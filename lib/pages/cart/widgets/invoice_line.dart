import 'package:flutter/material.dart';

class InvoiceLine extends StatelessWidget {
  final String label;
  final double amount;
  final double? fontSize;
  const InvoiceLine(
      {super.key, required this.label, required this.amount, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
        ),
        Row(
          children: amount > 0
              ? [
                  const Text(
                    "₱ ",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    "$amount",
                    style: TextStyle(
                        fontSize: fontSize ?? 25, fontWeight: FontWeight.bold),
                  ),
                ]
              : [
                  Text(
                    "--",
                    style: TextStyle(fontSize: fontSize ?? 25),
                  )
                ],
        ),
      ],
    );
  }
}
