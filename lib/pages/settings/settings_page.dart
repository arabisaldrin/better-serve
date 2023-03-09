import 'package:better_serve/components/flip_dialog.dart';
import 'package:better_serve/models/item_action.dart';
import 'package:better_serve/pages/manager/products/widgets/attribute_form.dart';
import 'package:better_serve/pages/manager/products/widgets/variation_form.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/attribute_setting.dart';
import 'widgets/custom_color_picker.dart';
import 'widgets/general_setting.dart';
import 'widgets/shop_setting.dart';
import 'widgets/variation_setting.dart';

enum BackSetting { color, variation, attribute }

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  BackSetting backSetting = BackSetting.color;

  List<Variation> variationTempalates = List.empty(growable: true);
  List<Attribute> attributeTemplates = List.empty(growable: true);

  Variation? editingVariation;
  Attribute? editingAttribute;

  late TabController _controller;
  late SettingsService settings;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    settings = Provider.of<SettingsService>(context, listen: false);

    variationTempalates = settings.variationTempalates;
    attributeTemplates = settings.attributeTemplates;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlipDialog(
      frontBuilder: (context, flip) {
        return DialogPane(
          tag: "settings",
          width: 600,
          builder: (context, toggleLoadding) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.settings),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Settings"),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    height: 2,
                  ),
                  TabBar(
                      controller: _controller,
                      indicatorColor: settings.primaryColor,
                      tabs: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "General",
                            style: TextStyle(color: settings.primaryColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Var./Attr. Templates",
                            style: TextStyle(color: settings.primaryColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Shop",
                            style: TextStyle(color: settings.primaryColor),
                          ),
                        )
                      ]),
                  const Divider(
                    height: 2,
                  ),
                  SizedBox(
                    height: 400,
                    width: 600,
                    child: TabBarView(controller: _controller, children: [
                      GeneralSetting(onFlip: (BackSetting view) {
                        backSetting = view;
                        flip();
                      }),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            VariationSetting(
                              variationTempalates,
                              onAdd: () {
                                backSetting = BackSetting.variation;
                                flip();
                              },
                              itemAction: (variation, action) {
                                switch (action) {
                                  case ItemAction.edit:
                                    setState(() {
                                      editingVariation = variation;
                                    });
                                    backSetting = BackSetting.variation;
                                    flip();
                                    break;
                                  case ItemAction.delete:
                                    setState(() {
                                      variationTempalates.remove(variation);
                                    });
                                    break;
                                }
                              },
                            ),
                            AttributeSetting(
                              attributeTemplates,
                              onAdd: () {
                                backSetting = BackSetting.attribute;
                                flip();
                              },
                              itemAction: (attribute, action) {
                                switch (action) {
                                  case ItemAction.edit:
                                    setState(() {
                                      editingAttribute = attribute;
                                    });
                                    backSetting = BackSetting.attribute;
                                    flip();
                                    break;
                                  case ItemAction.delete:
                                    setState(() {
                                      attributeTemplates.remove(attribute);
                                    });
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const ShopSetting()
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close")),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            toggleLoadding();

                            settings.set(
                                "variation_templates",
                                variationTempalates
                                    .map((e) => e.toJson())
                                    .toList());
                            settings.set(
                                "attribute_templates",
                                attributeTemplates
                                    .map((e) => e.toJson())
                                    .toList());

                            settings.save().then((value) {
                              toggleLoadding();
                              if (value != null) {
                                showToast(context,
                                    Text("Error: ${value.toString()}"));
                              } else {
                                showToast(
                                    context, const Text("Settings updated"));
                              }
                            });
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.save,
                                size: 20,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text("Save"),
                            ],
                          ))
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      backBuilder: (context, flip) {
        switch (backSetting) {
          case BackSetting.color:
            return CustomColorPicker(settings.primaryColor,
                (Color pickedColor) {
              settings.setPrimaryColor(pickedColor);
              flip();
            });
          case BackSetting.variation:
            return VariationForm(
              editingVariation,
              (v) {
                if (v != null) {
                  if (editingVariation == null) {
                    variationTempalates.add(v);
                  } else {
                    setState(() {
                      var index =
                          variationTempalates.indexOf(editingVariation!);
                      variationTempalates[index] = v;
                    });
                  }
                }
                editingVariation = null;
                flip();
              },
              onRemove: () {},
              title:
                  editingAttribute != null ? "Edit Template" : "Add Template",
            );
          case BackSetting.attribute:
            return AttributeForm(
              editingAttribute,
              (v) {
                if (v != null) {
                  if (editingAttribute == null) {
                    attributeTemplates.add(v);
                  } else {
                    setState(() {
                      var index = attributeTemplates.indexOf(editingAttribute!);
                      attributeTemplates[index] = v;
                    });
                  }
                }
                editingAttribute = null;
                flip();
              },
              onRemove: () {},
              title:
                  editingAttribute != null ? "Edit Template" : "Add Template",
            );
        }
      },
    );
  }
}
