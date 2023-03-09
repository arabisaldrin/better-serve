import 'dart:io';

import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve/components/flip_dialog.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve/models/media.dart';
import 'package:better_serve/services/media_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' show basename;
import 'package:provider/provider.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;
  const CategoryFormDialog({Key? key, this.category}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  String categoryName = "";
  String iconName = "";
  bool uploading = false;

  String selectingIcon = "";

  late TextEditingController _nameController;

  late SettingsService settings;

  @override
  void initState() {
    if (widget.category != null) {
      categoryName = widget.category!.name;
      iconName = basename(widget.category!.icon);
    }
    _nameController = TextEditingController(text: categoryName);
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppService, MediaService>(
      builder: (BuildContext context, appService, media, _) {
        return FlipDialog(
          frontBuilder: (context, flip) {
            return DialogPane(
              tag: widget.category == null
                  ? "add_category"
                  : "edit_category_${widget.category!.id}",
              width: 400,
              builder: (context, toggleLoadding) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                const Icon(Icons.add),
                                Text(
                                  widget.category == null
                                      ? "Create New Category"
                                      : "Edit Category",
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                                isDense: true,
                                labelText: 'Name',
                                icon: Icon(Icons.category))),
                        TextFormField(
                            readOnly: true,
                            controller: TextEditingController(text: iconName),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                isDense: true,
                                labelText: 'Logo',
                                icon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (iconName.isNotEmpty)
                                      Image.network(
                                        publicPath("/images/icons/$iconName"),
                                        width: 30,
                                      )
                                    else
                                      const Icon(Icons.image),
                                  ],
                                )),
                            onTap: () {
                              flip();
                            }),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  onPressed: () async {
                                    String name = _nameController.text;
                                    if (name.isEmpty) {
                                      showToast(
                                          context,
                                          const Text("Name is required"),
                                          ToastGravity.TOP);
                                      return;
                                    }
                                    toggleLoadding();
                                    if (widget.category == null) {
                                      appService
                                          .saveCategory(name, iconName)
                                          .then((_) {
                                        Navigator.of(context).pop();
                                      });
                                    } else {
                                      appService
                                          .updateCategory(widget.category!.id,
                                              name, iconName)
                                          .then((_) {
                                        Navigator.of(context).pop();
                                      });
                                    }
                                  },
                                  child: const Icon(
                                    Icons.check,
                                    size: 30,
                                  )),
                            )
                          ],
                        )
                      ]),
                );
              },
            );
          },
          backBuilder: (context, flip) {
            return DialogPane(
              tag: 'category_add',
              minHeight: 100,
              width: 450,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    children: const [
                      Icon(Icons.add),
                      Text("Select Icon"),
                    ],
                  ),
                  const Divider(),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: Wrap(children: [
                      for (Media item in media.icons) iconCard(item)
                    ]),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              selectingIcon = iconName;
                            });
                            flip();
                          },
                          child: const Text("Cancel")),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton(
                          onPressed: () async {
                            FilePickerResult? filePickerResult =
                                await FilePicker.platform.pickFiles();

                            if (filePickerResult != null) {
                              setState(() {
                                uploading = true;
                              });
                              var pickedFile = File(filePickerResult
                                  .files.single.path
                                  .toString());
                              await media.uploadIcon(pickedFile);
                            }
                          },
                          child: uploading
                              ? const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ))
                              : const Text("Upload New Icon")),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  iconName = selectingIcon;
                                });
                                flip();
                              },
                              child: const Text("Ok")))
                    ],
                  )
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget iconCard(Media item) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            selectingIcon = item.name;
          });
        },
        child: Container(
          decoration: selectingIcon == item.name
              ? BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: settings.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(5))
              : BoxDecoration(
                  border: Border.all(width: 1, color: Colors.transparent)),
          padding: const EdgeInsets.all(10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CachedNetworkImage(
              imageUrl: item.url,
              width: 40,
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            const SizedBox(
              height: 5,
            ),
          ]),
        ),
      ),
    );
  }
}
