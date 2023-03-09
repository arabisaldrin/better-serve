import 'package:better_serve/services/cart_service.dart';
import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve/models/cart_item.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve/components/order_form.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItemEditDialog extends StatefulWidget {
  final int index;
  final CartItem item;
  const CartItemEditDialog(this.index, this.item, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CartItemEditDialogState();
}

class _CartItemEditDialogState extends State<CartItemEditDialog>
    with TickerProviderStateMixin {
  int quantity = 1;
  Variation? variation;
  late List<Attribute> attributes;

  @override
  void initState() {
    if (widget.item.variation != null) {
      variation = widget.item.variation!.clone();
    }
    attributes = widget.item.attributes.map((e) => e.clone()).toList();
    quantity = widget.item.quantity;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CartItem item = widget.item;
    Product product = item.product;
    CartService cartService = Provider.of<CartService>(context, listen: false);

    return OrderForm(
      tag: "cart_item_update_${widget.index}",
      product: product,
      quantity: quantity,
      variation: variation,
      attributes: attributes,
      addons: item.addons,
      onComplete: (CartItem cartItem) {
        cartService.updateItem(item, cartItem);
        Navigator.of(context).pop();
      },
    );
  }
}
