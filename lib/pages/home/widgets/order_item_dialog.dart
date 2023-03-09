import 'package:better_serve/services/cart_service.dart';
import 'package:better_serve/models/cart_item.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve/components/order_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderItemDialog extends StatefulWidget {
  final Product product;
  const OrderItemDialog(this.product, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderItemDialogState();
}

class _OrderItemDialogState extends State<OrderItemDialog>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Product product = widget.product;
    CartService cartService = Provider.of<CartService>(context, listen: false);
    return OrderForm(
      tag: "product_${product.id}",
      product: product,
      quantity: 1,
      onComplete: (CartItem cartItem) {
        cartService.addItem(cartItem);
        Navigator.of(context).pop();
      },
    );
  }
}
