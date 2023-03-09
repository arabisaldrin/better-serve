import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:better_serve_lib/model/attribute.dart';

class AttributeForm extends StatefulWidget {
  final Attribute? value;
  final ValueChanged<Attribute?> callback;
  final VoidCallback onRemove;
  final String? title;
  final bool showTemplate;
  const AttributeForm(this.value, this.callback,
      {Key? key, required this.onRemove, this.title, this.showTemplate = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AttributeFormState();
}

class _AttributeFormState extends State<AttributeForm> {
  Attribute editingAttribute = Attribute(
      name: "",
      type: AttributeType.single,
      options:
          List.generate(2, (i) => AttributeOption(value: "", selected: false)));
  int? singleDefaultSelected = 0;
  bool ordering = false;

  List<AttributeOption> get options => editingAttribute.options;
  late SettingsService settings;
  @override
  void initState() {
    if (widget.value != null) editingAttribute = widget.value!.clone();
    settings = Provider.of<SettingsService>(context, listen: false);
    trySelectSingle();
    super.initState();
  }

  void trySelectSingle() {
    if (editingAttribute.type == AttributeType.single) {
      singleDefaultSelected = options.indexWhere((opt) => opt.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "attribute_form",
      width: 500,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                widget.title ?? "Add Attributes",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const Divider(),
            if (widget.showTemplate)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (Attribute attr in settings.attributeTemplates)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          editingAttribute = attr;
                          trySelectSingle();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 7),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: settings.primaryColor)),
                        child: Text(
                          attr.name,
                          style: TextStyle(color: settings.primaryColor),
                        ),
                      ),
                    )
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SelectFormField(
                      type: SelectFormFieldType.dropdown,
                      // icon: const Icon(Icons.category),
                      labelText: 'Type',
                      items: const [
                        {
                          'value': "Single",
                          'label': "Single",
                        },
                        {
                          'value': "Multiple",
                          'label': "Multiple",
                        }
                      ],
                      initialValue: editingAttribute.type.name,
                      onChanged: (val) => setState(() {
                            editingAttribute.type = val == "Single"
                                ? AttributeType.single
                                : AttributeType.multiple;
                          })),
                  TextField(
                    controller:
                        TextEditingController(text: editingAttribute.name),
                    decoration: const InputDecoration(
                        label: Text("Attribute Name"), isDense: true),
                    onChanged: (value) {
                      editingAttribute.name = value;
                    },
                  ),
                ],
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
            buildOptionsTable(),
            const Divider(
              height: 10,
            ),
            ordering
                ? const SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            setState(() {
                              ordering = true;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.sort),
                              Text("Reorder"),
                            ],
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      OutlinedButton(
                          onPressed: () {
                            setState(() {
                              options.add(AttributeOption(
                                  value: "",
                                  selected: false,
                                  order: options.length));
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add),
                              Text("Add Another"),
                            ],
                          )),
                    ],
                  ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      widget.callback(null);
                    },
                    child: const Text("Cancel")),
                const SizedBox(
                  width: 10,
                ),
                if (widget.value != null && !ordering)
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
                        if (ordering) {
                          setState(() {
                            ordering = false;
                          });
                          return;
                        }
                        if (editingAttribute.name.isEmpty) {
                          showToast(
                              context,
                              const Text("Attribute name is required!"),
                              ToastGravity.TOP);
                          return;
                        }
                        if (options.where((e) => e.value.isNotEmpty).isEmpty) {
                          showToast(
                              context,
                              const Text("At least 2 value is required!"),
                              ToastGravity.TOP);
                          return;
                        }
                        // set selected false for other in single type
                        if (editingAttribute.type == AttributeType.single) {
                          for (int i = 0; i < options.length; i++) {
                            AttributeOption opt = options[i];
                            opt.selected = singleDefaultSelected == i;
                          }
                        }

                        widget.callback(editingAttribute);
                      },
                      child: ordering
                          ? const Text("Done")
                          : const Icon(
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

  Widget buildOptionsTable() {
    return SizedBox(
        width: double.infinity,
        child: Table(
          columnWidths: {
            0: const FractionColumnWidth(0.1),
            1: const FractionColumnWidth(0.65),
            2: FractionColumnWidth(ordering ? 0.1 : 0.15),
            3: const FractionColumnWidth(0.1),
          },
          children: [
            TableRow(children: [
              const Center(child: Text("#")),
              const Text("Option"),
              Text(ordering ? "" : "Selected"),
              const Text(""),
            ]),
            // ignore: prefer_const_constructors
            TableRow(children: const [
              Divider(),
              Divider(),
              Divider(),
              Divider(),
            ]),
            for (int i = 0; i < options.length; i++) createVariationRow(i)
          ],
        ));
  }

  TableRow createVariationRow(int i) {
    AttributeOption option = options[i];
    return TableRow(children: [
      Container(
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Text((i + 1).toString())),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: TextField(
          enabled: !ordering,
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
      ordering
          ? moveArrow(
              const Icon(Icons.arrow_drop_down), i == options.length - 1, () {
              swapOption(i, 1);
            })
          : editingAttribute.type == AttributeType.single
              ? Radio(
                  toggleable: true,
                  value: i,
                  groupValue: singleDefaultSelected,
                  onChanged: (val) {
                    setState(() {
                      singleDefaultSelected = val;
                    });
                  },
                )
              : Checkbox(
                  value: option.selected,
                  onChanged: (value) {
                    setState(() {
                      option.selected = value!;
                    });
                  }),
      ordering
          ? moveArrow(const Icon(Icons.arrow_drop_up), i == 0, () {
              swapOption(i, -1);
            })
          : Material(
              color: Colors.transparent,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      options.removeAt(i);
                    });
                  },
                  splashRadius: 20,
                  icon: const Icon(Icons.delete_outline)))
    ]);
  }

  Widget moveArrow(Icon icon, bool disable, Function() action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(3)),
          onPressed: disable ? () {} : action,
          child: disable
              ? Icon(
                  icon.icon,
                  color: Colors.grey,
                )
              : icon),
    );
  }

  void swapOption(int index, int dir) {
    AttributeOption option = options[index];
    option.order = index + dir;
    options[index + dir].order = index;
    sortOptions();
    trySelectSingle();
  }

  void sortOptions() {
    setState(() {
      options.sort((a, b) => a.order.compareTo(b.order));
    });
  }
}
