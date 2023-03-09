import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_order_dialog.dart';

class PendingOrderCard extends StatelessWidget {
  final Order order;
  PendingOrderCard({required this.order, super.key});

  late SettingsService settings;
  @override
  Widget build(BuildContext context) {
    settings = Provider.of<SettingsService>(context, listen: false);
    return SizedBox(
      width: 370,
      height: 250,
      child: Hero(
        tag: "order_${order.id}",
        child: Card(
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: orderStatusColor[order.status].withAlpha(100),
              ),
              borderRadius: BorderRadius.circular(5)),
          child: InkWell(
            onTap: () {
              pushHeroDialog(ViewOrderDialog(order: order), true);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "#${order.queueNumber}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 10),
                          decoration: BoxDecoration(
                              color: orderStatusColor[order.status],
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            order.statusName,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    height: 2,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (OrderItem item in order.items.take(3)) ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: publicPath(item.productImg),
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
                                      if (item.variationValue != null) {
                                        str += " ${item.variationValue}";
                                      }
                                      str += " ${item.productName}";
                                      if (item.addons.isNotEmpty) {
                                        str += " with ";
                                        for (var i = 0;
                                            i < item.addons.length;
                                            i++) {
                                          OrderItemAddon addon = item.addons[i];
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
                                    for (OrderItemAttribute attr
                                        in item.attributes)
                                      Builder(
                                        builder: (context) {
                                          String str = "${attr.name} :";
                                          for (var i = 0;
                                              i < attr.values.length;
                                              i++) {
                                            String opt = attr.values[i];
                                            int len = attr.values.length;
                                            str +=
                                                "$opt ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                          }
                                          return Text(
                                            str,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          );
                                        },
                                      ),
                                  ],
                                ],
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          height: 4,
                        ),
                      ]
                    ],
                  )),
                  if (order.items.length > 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: settings.primaryColor)),
                          child: Text(
                            "Click to view all",
                            style: TextStyle(color: settings.primaryColor),
                          ),
                        ),
                      ],
                    )
                  // const Divider(),
                  // Text(
                  //   "Total: ₱${NumberFormat("#,###").format(order.totalAmount)}",
                  //   style: const TextStyle(
                  //       fontSize: 20, fontWeight: FontWeight.bold),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
