import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve_lib/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CustomColorPicker extends StatefulWidget {
  final Color color;
  final Null Function(Color pickedColor) onSelect;
  const CustomColorPicker(this.color, this.onSelect, {super.key});

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late Color selectedColor;

  @override
  void initState() {
    selectedColor = widget.color;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "settings",
      width: 320,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.only(left: 5, top: 5, right: 5),
            child: Text("Pick Color"),
          ),
          BlockPicker(
            pickerColor: widget.color,
            onColorChanged: (c) => setState(() {
              selectedColor = c;
            }),
            layoutBuilder: (context, colors, child) {
              return SizedBox(
                width: 300,
                height: 230,
                child: GridView.count(
                  crossAxisCount: 6,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  children: [
                    child(Pallete.hexToColor("#BB6F19")),
                    for (Color color in colors) child(color)
                  ],
                ),
              );
            },
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () {
                    widget.onSelect(selectedColor);
                  },
                  child: const Text("Ok"))
            ],
          )
        ]),
      ),
    );
  }
}
