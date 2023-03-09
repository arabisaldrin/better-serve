import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve/components/flip_dialog.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/pages/manager/products/widgets/variation_form.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' show basename;
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

import 'attribute_form.dart';
import 'image_form.dart';

enum BackForm { variation, attribute, image }

class ProductFormDialog extends StatefulWidget {
  final BuildContext ctx;
  final Product? product;
  final Category? category;
  const ProductFormDialog(this.ctx, this.product, this.category, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog>
    with TickerProviderStateMixin {
  String name = "";
  int? basePrice;
  Variation? variation;
  List<Attribute> attributes = List.empty(growable: true);
  Attribute? editingAttribute;

  BackForm backForm = BackForm.variation;

  Product? product;
  Category? selectedCategory;
  String? imageName;
  bool allowAddon = true;

  late TextEditingController _priceController;

  late AppService _appService;
  late SettingsService settings;

  get variationPriceRange {
    List<VariationOption> options = variation!.options;
    options.sort((a, b) => a.price.compareTo(b.price));
    return "₱${options.first.price} - ₱${options.last.price}";
  }

  @override
  void initState() {
    product = widget.product;
    if (product != null) {
      selectedCategory = product!.category;
      name = product!.name;
      basePrice = product!.basePrice;
      product = widget.product;
      imageName = basename(product!.imgPath);
      allowAddon = product!.allowAddon;

      if (widget.product?.variation != null) {
        variation = widget.product?.variation!.clone();
      }
      attributes = product!.attributes.map((e) => e.clone()).toList();
    }
    if (widget.category != null) selectedCategory = widget.category!;
    _priceController = TextEditingController(
        text: variation != null
            ? variationPriceRange
            : (basePrice ?? "").toString());
    _priceController.addListener(() {
      final text = _priceController.text;
      _priceController.value = _priceController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(
      builder: (context, appService, _) {
        _appService = appService;

        return FlipDialog(
          frontBuilder: (context, flip) {
            return mainForm(flip);
          },
          backBuilder: (context, flip) {
            return backForm == BackForm.variation
                ? VariationForm(variation, (Variation? result) {
                    if (result != null) {
                      setState(() {
                        variation = result;
                      });
                    }
                    flip();
                  }, onRemove: () {
                    setState(() {
                      variation = null;
                      _priceController.text = (basePrice ?? "").toString();
                    });
                  }, showTemplate: true)
                : backForm == BackForm.attribute
                    ? AttributeForm(
                        editingAttribute,
                        (Attribute? result) {
                          if (result != null) {
                            if (editingAttribute == null) {
                              if (attributes.getFirstOrNull(
                                    (e) => e.name == result.name,
                                  ) !=
                                  null) {
                                showToast(
                                    context,
                                    const Text(
                                      "Attribute name must be unique!",
                                      style: TextStyle(color: Colors.red),
                                    ));
                                return;
                              }
                              setState(() {
                                attributes.add(result);
                                flip();
                              });
                            } else {
                              var index = attributes.indexOf(editingAttribute!);
                              attributes[index] = result;
                              flip();
                            }
                          } else {
                            flip();
                          }
                        },
                        onRemove: () {
                          attributes.remove(editingAttribute);
                        },
                        showTemplate: true,
                      )
                    : ImageForm(imageName, (String? value) {
                        if (value != null) {
                          setState(() {
                            imageName = value;
                          });
                        }
                        flip();
                      });
          },
        );
      },
    );
  }

  Widget mainForm(void Function() flip) {
    final List<Map<String, dynamic>> categorySelectItems = [
      for (Category c in _appService.categories)
        {
          'value': c.id,
          'label': c.name,
          'icon': CachedNetworkImage(
            imageUrl: publicPath(c.icon),
            errorWidget: (context, url, error) {
              return const Center(
                child: Icon(Icons.error),
              );
            },
            width: 20,
          ),
        }
    ];
    return DialogPane(
      tag: "product_${product == null ? "new" : product!.id}",
      width: 500,
      builder: (context, toggleLoadding) {
        return Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: const [
                    Icon(Icons.add),
                    Text(
                      "Create New Item",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const Divider(),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Name', icon: Icon(Icons.inventory)),
                initialValue: name,
                onChanged: (val) {
                  setState(() {
                    name = val;
                  });
                },
              ),
              SelectFormField(
                type: SelectFormFieldType.dropdown,
                icon: const Icon(Icons.category),
                labelText: 'Category',
                items: categorySelectItems,
                initialValue: selectedCategory?.id.toString(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = _appService.categories
                        .singleWhere((c) => c.id.toString() == val);
                  });
                },
              ),
              TextFormField(
                  readOnly: variation != null,
                  controller: _priceController,
                  keyboardType: variation != null
                      ? TextInputType.text
                      : TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onChanged: (newValue) {
                    basePrice = int.tryParse(newValue);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    icon: Icon(MdiIcons.currencyPhp),
                  )),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: imageName),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Image',
                    icon: Icon(
                      Icons.image,
                      size: 22,
                    )),
                onTap: () {
                  backForm = BackForm.image;
                  flip();
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    MdiIcons.foodVariant,
                    color: context.isDarkMode
                        ? Colors.white.withAlpha(170)
                        : Colors.grey,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("Allow Addon?"),
                  Checkbox(
                      value: allowAddon,
                      onChanged: (v) {
                        setState(() {
                          allowAddon = v!;
                        });
                      }),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              if (variation != null) ...[
                Text("Variation",
                    style: TextStyle(
                      color: settings.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                if (variation != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(variation!.name,
                          style: const TextStyle(
                            fontSize: 15,
                          )),
                      Wrap(
                        spacing: 10,
                        children: [
                          for (VariationOption option in variation!.options)
                            Chip(
                              backgroundColor: option.selected
                                  ? settings.primaryColor
                                  : null,
                              label: Text("${option.value} | ₱${option.price}",
                                  style: TextStyle(
                                    color: option.selected
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                            )
                        ],
                      )
                    ],
                  ),
                const Divider(),
              ],
              if (attributes.isNotEmpty) ...[
                Text("Attributes",
                    style: TextStyle(
                      color: settings.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                for (Attribute attr in attributes)
                  Card(
                    // margin: const EdgeInsets.only(bottom: 5),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          backForm = BackForm.attribute;
                          editingAttribute = attr;
                          flip();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit_note),
                                Text(attr.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ))
                              ],
                            ),
                            Wrap(
                              spacing: 10,
                              children: [
                                for (AttributeOption option in attr.options)
                                  Chip(
                                    backgroundColor: option.selected
                                        ? settings.primaryColor
                                        : null,
                                    label: Text(option.value,
                                        style: TextStyle(
                                          color: option.selected
                                              ? Colors.white
                                              : context.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                        )),
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ],
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          backForm = BackForm.attribute;
                          editingAttribute = null;
                          flip();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(attributes.isEmpty
                                ? Icons.add
                                : Icons.edit_note_sharp),
                            const Text("Add Attributes"),
                          ],
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          backForm = BackForm.variation;
                          flip();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(variation == null
                                ? Icons.add
                                : Icons.edit_note_sharp),
                            Text(variation == null
                                ? "Enable Variation"
                                : "Edit Variation"),
                          ],
                        )),
                  ),
                ],
              ),
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        close();
                      },
                      child: const Text("Cancel")),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (name.isEmpty) {
                            showToast(
                                context,
                                const Text("Product name is required!"),
                                ToastGravity.TOP);
                            return;
                          }
                          if (selectedCategory == null) {
                            showToast(
                                context,
                                const Text("Category is required!"),
                                ToastGravity.TOP);
                            return;
                          }
                          toggleLoadding();
                          if (product != null) {
                            await _appService.updateProduct(
                              product!.id,
                              name,
                              basePrice,
                              selectedCategory!.id,
                              variation,
                              attributes,
                              imageName,
                              allowAddon,
                            );
                          } else {
                            await _appService.saveProduct(
                              name,
                              basePrice,
                              selectedCategory!.id,
                              variation,
                              attributes,
                              imageName,
                              allowAddon,
                            );
                          }
                          close();
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
        );
      },
    );
  }

  void close() {
    setState(() {
      attributes.clear();
      variation = null;
    });
    Navigator.of(context).pop();
  }
}
