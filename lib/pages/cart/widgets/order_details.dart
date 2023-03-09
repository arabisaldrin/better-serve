import 'package:better_serve/services/cart_service.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve/models/cart_item.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatelessWidget {
  OrderDetails({super.key});

  late SettingsService settings;
  late CartService cart;

  @override
  Widget build(BuildContext context) {
    settings = Provider.of<SettingsService>(context, listen: false);
    cart = Provider.of<CartService>(context, listen: false);
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.receipt),
              SizedBox(
                width: 10,
              ),
              Text(
                "Order Details",
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("(${cart.itemCount}) Items"),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    height: 5,
                  ),
                  for (CartItem item in cart.items) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: publicPath(item.product.imgPath),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                String str = "${item.quantity}x";
                                if (item.variation != null) {
                                  VariationOption? option = item
                                      .variation!.options
                                      .getFirstOrNull((e) => e.selected);
                                  str += " ${option?.value}";
                                }
                                str += " ${item.product.name}";
                                if (item.addons.isNotEmpty) {
                                  str += " with ";
                                  for (var i = 0; i < item.addons.length; i++) {
                                    Addon addon = item.addons[i];
                                    int len = item.addons.length;
                                    str +=
                                        "${addon.name} ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                  }
                                }
                                return Text(
                                  str,
                                  style: const TextStyle(fontSize: 15),
                                );
                              },
                            ),
                            if (item.attributes.isNotEmpty) ...[
                              for (Attribute attr in item.attributes)
                                Builder(
                                  builder: (context) {
                                    List<AttributeOption> options = attr.options
                                        .where((e) => e.selected)
                                        .toList();
                                    String str = "${attr.name} :";
                                    for (var i = 0; i < options.length; i++) {
                                      String opt = options[i].value;
                                      int len = options.length;
                                      str +=
                                          "$opt ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                    }
                                    return Text(
                                      str,
                                      style: const TextStyle(fontSize: 13),
                                    );
                                  },
                                ),
                            ],
                          ],
                        )),
                      ],
                    ),
                    const Divider(
                      height: 5,
                    )
                  ],
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Items Total"),
                        Text(
                          "₱${cart.totalAmount}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Discount"),
                        Text(
                          "--",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Grand Total",
                          style: TextStyle(
                              fontSize: 20, color: settings.primaryColor),
                        ),
                        Text(
                          "₱${cart.totalAmount}",
                          style: TextStyle(
                              fontSize: 20, color: settings.primaryColor),
                        ),
                      ],
                    ),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
