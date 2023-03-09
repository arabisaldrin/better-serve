import 'package:better_serve/components/simple_chip.dart';
import 'package:better_serve/models/option_select_item.dart';
import 'package:flutter/material.dart';

class SingleOptionSelect extends StatefulWidget {
  final List<OptionSelectItem> options;
  final int? initialValue;
  final ValueChanged<OptionSelectItem> onSelect;
  final Color? color;
  const SingleOptionSelect(
      {Key? key,
      required this.options,
      this.initialValue,
      required this.onSelect,
      this.color})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleOptionSelectState();
}

class _SingleOptionSelectState extends State<SingleOptionSelect> {
  ///
  /// Currently selected index
  ///
  int? selectedIndex;

  @override
  void initState() {
    if (widget.initialValue != null &&
        widget.initialValue! >= 0 &&
        widget.initialValue! < widget.options.length) {
      selectedIndex = widget.initialValue!;
    } else {
      int index = widget.options.indexWhere((element) => element.selected);
      if (index != -1) selectedIndex = index;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var index = 0;
    return Wrap(
      spacing: 5,
      children: [
        for (int x = 0; x < widget.options.length; x++) ...[
          chipBuilder(context, index++),
        ]
      ],
    );
  }

  Widget chipBuilder(BuildContext context, int index) {
    OptionSelectItem option = widget.options[index];
    bool isActive = selectedIndex == index;

    return SimpleChip(
      text: option.text,
      selected: isActive,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        widget.onSelect(option);
      },
      color: widget.color,
    );
  }
}
