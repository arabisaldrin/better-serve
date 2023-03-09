import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class VariationForm extends StatefulWidget {
  final Variation? value;
  final ValueChanged<Variation?> callback;
  final VoidCallback onRemove;
  final String? title;
  final bool showTemplate;
  const VariationForm(this.value, this.callback,
      {Key? key, required this.onRemove, this.title, this.showTemplate = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _VariationFormState();
}

class _VariationFormState extends State<VariationForm> {
  late Variation editingVariation;
  int? defaultSelected;
  late SettingsService settings;
  @override
  void initState() {
    if (widget.value != null) {
      editingVariation = widget.value!.clone();
      var selectedIndex =
          editingVariation.options.indexWhere((e) => e.selected);
      if (selectedIndex != -1) {
        defaultSelected = selectedIndex;
      }
    } else {
      editingVariation = Variation(
          name: "", options: List.generate(2, (i) => VariationOption()));
    }
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "variation_form",
      width: 500,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                widget.title ?? "Add Variation",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const Divider(),
            if (widget.showTemplate)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (Variation variation in settings.variationTempalates)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          editingVariation = variation;
                          defaultSelected = variation.options
                              .indexWhere((opt) => opt.selected);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 7),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: settings.primaryColor)),
                        child: Text(
                          variation.name,
                          style: TextStyle(color: settings.primaryColor),
                        ),
                      ),
                    )
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: TextEditingController(text: editingVariation.name),
                decoration: const InputDecoration(
                    label: Text("Variation Name"), isDense: true),
                onChanged: (value) {
                  editingVariation.name = value;
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text("Options",
                style: TextStyle(
                  color: settings.primaryColor,
                )),
            const Divider(
              height: 15,
            ),
            buildVariationsTable(),
            Center(
                child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        editingVariation.options.add(VariationOption());
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add),
                        Text("Add Another"),
                      ],
                    ))),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      widget.callback(null);
                      editingVariation = Variation(
                          name: "",
                          options: List.generate(2, (i) => VariationOption()));
                    },
                    child: const Text("Cancel")),
                const SizedBox(
                  width: 10,
                ),
                if (widget.value != null)
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () {
                        widget.onRemove();
                        widget.callback(null);
                      },
                      child: const Text("Remove")),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        if (editingVariation.name.isEmpty) {
                          showToast(
                              context,
                              const Text("Variation name is required!"),
                              ToastGravity.TOP);
                          return;
                        }
                        if (editingVariation.options.length < 2) {
                          showToast(
                              context,
                              const Text("At least 2 options is required!"),
                              ToastGravity.TOP);
                          return;
                        }
                        widget.callback(editingVariation);
                        setState(() {
                          for (var i = 0;
                              i < editingVariation.options.length;
                              i++) {
                            VariationOption v = editingVariation.options[i];
                            if (v.isBlank) {
                              editingVariation.options.removeAt(i);
                            }
                          }
                          for (int i = 0;
                              i < editingVariation.options.length;
                              i++) {
                            VariationOption opt = editingVariation.options[i];
                            opt.selected = defaultSelected == i;
                          }
                        });
                      },
                      child: const Icon(
                        Icons.check,
                        size: 30,
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildVariationsTable() {
    return SizedBox(
        width: double.infinity,
        child: Table(
          columnWidths: const {
            0: FractionColumnWidth(0.1),
            1: FractionColumnWidth(0.5),
            2: FractionColumnWidth(0.15),
            3: FractionColumnWidth(0.15),
            4: FractionColumnWidth(0.1),
          },
          children: [
            const TableRow(children: [
              Center(child: Text("#")),
              Text("Option"),
              Text("Price"),
              Text("Selected"),
              Text(""),
            ]),
            // ignore: prefer_const_constructors
            TableRow(children: const [
              Divider(),
              Divider(),
              Divider(),
              Divider(),
              Divider(),
            ]),
            for (int i = 0; i < editingVariation.options.length; i++)
              createVariationRow(i)
          ],
        ));
  }

  TableRow createVariationRow(int i) {
    VariationOption option = editingVariation.options[i];
    return TableRow(children: [
      Container(
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Text((i + 1).toString())),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: TextField(
          controller: TextEditingController(
            text: option.value,
          ),
          onChanged: (value) {
            option.value = value;
          },
          decoration: const InputDecoration(isDense: true),
          textInputAction: TextInputAction.next,
        ),
      ),
      TextField(
        textAlign: TextAlign.end,
        controller: TextEditingController(
          text: (option.price == 0 ? "" : option.price).toString(),
        ),
        onChanged: (value) {
          int? v = int.tryParse(value);
          if (v != null) option.price = v;
        },
        decoration: const InputDecoration(isDense: true),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
      Radio(
        toggleable: true,
        value: i,
        groupValue: defaultSelected,
        onChanged: (val) {
          setState(() {
            defaultSelected = val;
          });
        },
      ),
      Material(
          color: Colors.transparent,
          child: IconButton(
              onPressed: () {
                setState(() {
                  editingVariation.options.removeAt(i);
                });
              },
              splashRadius: 20,
              icon: const Icon(Icons.delete_outline)))
    ]);
  }
}
