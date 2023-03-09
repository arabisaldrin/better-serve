import 'package:better_serve/pages/manager/products/widgets/image_form.dart';
import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve/components/flip_dialog.dart';
import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class AddonFormDialog extends StatefulWidget {
  final Addon? addon;
  const AddonFormDialog({super.key, this.addon});

  @override
  State<AddonFormDialog> createState() => _AddonFormDialogState();
}

class _AddonFormDialogState extends State<AddonFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  String imageName = "";

  @override
  void initState() {
    Addon? addon = widget.addon;
    _nameController = TextEditingController(text: addon?.name);
    _priceController = TextEditingController(text: addon?.price.toString());

    if (addon != null) {
      imageName = basename(addon.imgPath);
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Addon? addon = widget.addon;
    return Consumer<AppService>(builder: (context, appService, _) {
      return FlipDialog(
        frontBuilder: (context, flip) {
          return DialogPane(
            tag: "addon_${addon == null ? "new" : addon.id}",
            width: 400,
            builder: (context, toggleLoadding) {
              return Container(
                padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: addon == null
                          ? Row(
                              children: const [
                                Icon(Icons.add),
                                Text(
                                  "Create New Addon",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            )
                          : Row(
                              children: const [
                                Icon(Icons.edit),
                                Text(
                                  "Edit Addon",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Name',
                          icon: Icon(Icons.text_fields_sharp)),
                      onChanged: (val) {},
                    ),
                    TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
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
                          flip();
                        }),
                    const Divider(),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel")),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isEmpty) {
                              showToast(
                                  context, const Text("Name is required!"));
                              return;
                            }
                            if (_priceController.text.isEmpty) {
                              showToast(
                                  context, const Text("Price is required!"));
                              return;
                            }
                            if (imageName.isEmpty) {
                              showToast(
                                  context, const Text("Image is required!"));
                              return;
                            }
                            int price = int.parse(_priceController.text);
                            toggleLoadding();
                            if (addon != null) {
                              appService
                                  .updateAddon(addon, _nameController.text,
                                      price, imageName)
                                  .then((value) {
                                Navigator.of(context).pop();
                              });
                            } else {
                              appService
                                  .saveAddon(
                                      _nameController.text, price, imageName)
                                  .then((value) {
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: const Icon(Icons.check),
                        ))
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
        backBuilder: (context, flip) {
          return ImageForm(
            imageName,
            (String? value) {
              if (value != null) {
                setState(() {
                  imageName = value;
                });
              }
              flip();
            },
          );
        },
      );
    });
  }
}
