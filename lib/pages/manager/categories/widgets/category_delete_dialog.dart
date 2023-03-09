import 'package:better_serve/components/custom_dialog.dart';
import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryDeleteDialog extends StatefulWidget {
  final Category category;
  const CategoryDeleteDialog(this.category, {super.key});

  @override
  State<CategoryDeleteDialog> createState() => _CategoryDeleteDialogState();
}

class _CategoryDeleteDialogState extends State<CategoryDeleteDialog> {
  bool deleting = false;

  @override
  Widget build(BuildContext context) {
    Category category = widget.category;
    return Consumer<AppService>(builder: (context, appService, _) {
      return CustomDialog(
        title: "Delete Category?",
        content: "Are you sure you want to delete (${category.name})",
        positiveBtnText: "Yes",
        negativeBtnText: "Cancel",
        type: DialogType.error,
        icon: const CircleAvatar(
          maxRadius: 40.0,
          backgroundColor: Colors.redAccent,
          child: Icon(
            Icons.question_mark_outlined,
            size: 30,
            color: Colors.white,
          ),
        ),
        positiveBtnPressed: deleting
            ? null
            : () {
                setState(() {
                  deleting = true;
                });
                appService.deleteCategory(category.id).then((value) {
                  if (value != null) {
                    //  show error
                  } else {
                    showToast(
                        context, Text("Category (${category.name}) deleted"));
                    Navigator.of(context).pop();
                  }
                });
              },
      );
    });
  }
}
