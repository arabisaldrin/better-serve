import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class NumSpinner extends StatefulWidget {
  final int initialValue;
  final int? minValue;
  final bool Function(int value) onChange;
  const NumSpinner(this.initialValue, this.onChange, {Key? key, this.minValue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QtyNumSpinnerState();
}

class _QtyNumSpinnerState extends State<NumSpinner> {
  late int value;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant NumSpinner oldWidget) {
    value = widget.initialValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        actionBtn(MdiIcons.minus, () {
          if (widget.onChange(value - 1)) {
            setState(() {
              --value;
            });
          }
        }, widget.minValue != null && widget.minValue! >= value),
        SizedBox(
          width: 50,
          child: Text(value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
              )),
        ),
        actionBtn(MdiIcons.plus, () {
          if (widget.onChange(value + 1)) {
            setState(() {
              ++value;
            });
          }
        }),
      ],
    );
  }

  Widget actionBtn(IconData icon, VoidCallback onTap, [bool disabled = false]) {
    return OutlinedButton(
      onPressed: disabled ? null : onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(0),
        fixedSize: const Size.square(35),
        side: disabled ? const BorderSide(color: Colors.grey) : null,
        shape: const CircleBorder(),
      ),
      child: Icon(icon),
    );
  }
}
