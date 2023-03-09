import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve/components/outlined_btn.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

class MoveCategoryDialog extends StatefulWidget {
  final List<Product> items;
  final VoidCallback onComplete;
  const MoveCategoryDialog(
      {required this.items, super.key, required this.onComplete});

  @override
  State<MoveCategoryDialog> createState() => _MoveCategoryDialogState();
}

class _MoveCategoryDialogState extends State<MoveCategoryDialog> {
  int? selectedCategory;
  bool moving = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, appService, _) {
      final List<Map<String, dynamic>> categorySelectItems = [
        for (Category c in appService.categories)
          {
            'value': c.id,
            'label': c.name,
          }
      ];
      return DialogPane(
          tag: "move_category",
          width: 400,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text("Select category"),
              const Divider(),
              SelectFormField(
                type: SelectFormFieldType.dropdown,
                icon: const Icon(Icons.category),
                labelText: 'Category',
                items: categorySelectItems,
                onChanged: (val) {
                  setState(() {
                    selectedCategory = int.parse(val);
                  });
                },
              ),
              const Divider(),
              Row(
                children: [
                  OutlinedBtn(
                      onPressed: moving
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text("Cancel")),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: moving
                          ? null
                          : () {
                              if (selectedCategory != null) {
                                setState(() {
                                  moving = true;
                                });
                                appService
                                    .changeCategory(
                                        widget.items, selectedCategory!)
                                    .then((value) {
                                  widget.onComplete();
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                      child: moving
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ))
                          : const Text("Ok"),
                    ),
                  )
                ],
              )
            ]),
          ));
    });
  }
}
