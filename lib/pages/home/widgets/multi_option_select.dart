import 'package:better_serve/components/simple_chip.dart';
import 'package:better_serve/models/option_select_item.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:flutter/material.dart';

class MultiOptionSelect extends StatefulWidget {
  final List<OptionSelectItem> options;
  final ValueChanged<List<OptionSelectItem>> onSelect;
  final Color? color;
  final Function(OptionSelectItem item)? isItemSelected;
  const MultiOptionSelect(
      {Key? key,
      required this.options,
      required this.onSelect,
      this.color,
      this.isItemSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiOptionSelectState();
}

class _MultiOptionSelectState extends State<MultiOptionSelect> {
  List<OptionSelectItem> selected = List.empty(growable: true);

  @override
  void initState() {
    for (var i = 0; i < widget.options.length; i++) {
      var item = widget.options[i];
      if (item.selected || widget.isItemSelected?.call(item)) {
        selected.add(item);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var parts = partition(widget.options, 4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int x = 0; x < parts.length; x++) ...[
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              for (int y = 0; y < parts[x].length; y++) ...[
                const SizedBox(
                  width: 10,
                ),
                chipBuilder(context, parts[x][y]),
              ],
            ],
          ),
        ]
      ],
    );
  }

  Widget chipBuilder(BuildContext context, OptionSelectItem option) {
    bool isActive = selected.contains(option);

    return SimpleChip(
      text: option.text,
      selected: isActive,
      onTap: () {
        setState(() {
          if (selected.contains(option)) {
            selected.remove(option);
          } else {
            selected.add(option);
          }
          widget.onSelect(selected);
        });
      },
      color: widget.color,
    );
  }
}
