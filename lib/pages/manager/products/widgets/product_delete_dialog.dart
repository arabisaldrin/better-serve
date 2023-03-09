import 'package:better_serve/components/custom_dialog.dart';
import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDeleteDialog extends StatefulWidget {
  final List<Product> product;
  final VoidCallback callback;
  const ProductDeleteDialog(this.product, this.callback, {super.key});

  @override
  State<ProductDeleteDialog> createState() => _ProductDeleteDialogState();
}

class _ProductDeleteDialogState extends State<ProductDeleteDialog> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    List<Product> products = widget.product;
    return Consumer<AppService>(builder: (context, appService, _) {
      return CustomDialog(
        title: "Delete Product${products.length > 1 ? "s" : ""}?",
        content:
            "Are you sure you want to delete ${products.length} product${products.length > 1 ? "s" : ""}?",
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
                appService.deleteProducts(products).then((value) {
                  if (value != null) {
                    //  show error
                  } else {
                    showToast(
                        context, Text("${products.length} Products deleted"));
                    Navigator.of(context).pop();
                    widget.callback();
                  }
                });
              },
      );
    });
  }
}
