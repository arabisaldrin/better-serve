import 'package:better_serve/pages/cart/widgets/invoice_line.dart';
import 'package:better_serve/services/printer_service.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve_lib/model/discount.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderPlacedDialog extends StatelessWidget {
  final Order order;
  final double tenderAmount;
  final double changeAmount;
  OrderPlacedDialog(
      {super.key,
      required this.order,
      required this.tenderAmount,
      required this.changeAmount});

  final PrinterService _printer = PrinterService.instance;

  Widget itemText(String text, [double size = 15]) {
    return Text(
      text,
      style: TextStyle(fontSize: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    Discount? discount = order.coupon?.discount ??
        (order.discountAmount != null
            ? Discount(DiscountType.fromValue(order.discountType!),
                order.discountAmount!)
            : null);
    double discountAmount = 0;
    if (discount != null) {
      if (discount.type == DiscountType.fixed) {
        discountAmount = discount.value.toDouble();
      } else {
        discountAmount =
            roundDouble(order.orderAmount * (discount.value / 100), 2);
      }
    }

    return DialogPane(
      tag: "order_placed",
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check),
                    Text(
                      "Order Placed",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Text(
                  "#${order.queueNumber}  ",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Items:",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  for (OrderItem item in order.items) ...[
                    Wrap(
                      children: [
                        itemText("${item.quantity} "),
                        if (item.variationValue != null)
                          itemText("${item.variationValue} "),
                        itemText(item.productName),
                        if (item.addons.isNotEmpty) ...[
                          itemText(" with "),
                          for (var i = 0; i < item.addons.length; i++)
                            Builder(builder: (context) {
                              OrderItemAddon addon = item.addons[i];
                              int len = item.addons.length;
                              return itemText(
                                  "${addon.name} ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}");
                            })
                        ]
                      ],
                    ),
                    if (item.attributes.isNotEmpty) ...[
                      for (OrderItemAttribute attr in item.attributes)
                        Row(
                          children: [
                            itemText("    ${attr.name} : "),
                            for (var i = 0; i < attr.values.length; i++)
                              Builder(builder: (context) {
                                dynamic value = attr.values[i];
                                int len = attr.values.length;
                                return itemText(
                                    "$value ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}");
                              })
                          ],
                        ),
                    ],
                    const Divider(),
                  ],
                  const Text(
                    "Charge Details:",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Card(
                    margin: const EdgeInsets.all(0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Order Amount"),
                            Text(
                              "₱${NumberFormat("#,###").format(order.orderAmount)}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        const Divider(),
                        Builder(builder: (context) {
                          String str = "Discounts";
                          if (order.coupon != null) {
                            str += " (${order.coupon?.description})";
                          } else if (discount != null &&
                              discount.type == DiscountType.rate &&
                              discount.value != 0) {
                            str += " (${discount.value}%)";
                          }
                          return InvoiceLine(
                            label: str,
                            amount: discountAmount,
                            fontSize: 20,
                          );
                        }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Grand Total"),
                            Text(
                              "₱${NumberFormat("#,###").format(order.grandTotal)}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tendered"),
                            Text(
                              "₱${NumberFormat("#,###").format(tenderAmount)}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Change",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "₱${NumberFormat("#,###").format(changeAmount)}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            Row(
              children: [
                OutlinedButton(
                    onPressed: () {
                      _printer.printReceipt(order);
                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 20,
                        ),
                        Text("Print Receipt"),
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Done"),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
