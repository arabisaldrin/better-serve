import 'package:better_serve/pages/cart/widgets/coupon_dialog.dart';
import 'package:better_serve/pages/cart/widgets/discount_dialog.dart';
import 'package:better_serve/pages/cart/widgets/order_placed.dart';
import 'package:better_serve/services/cart_service.dart';
import 'package:better_serve/pages/cart/widgets/invoice_line.dart';
import 'package:better_serve/pages/cart/widgets/tender_dialog.dart';
import 'package:better_serve/services/printer_service.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/services/order_service.dart';
import 'package:better_serve/pages/cart/widgets/cart_item_card.dart';
import 'package:better_serve/models/cart_item.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:better_serve_lib/model/discount.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late SwipeActionController swipeController;
  late SettingsService settings;

  late PrinterService printer;

  @override
  void initState() {
    swipeController = SwipeActionController();
    settings = Provider.of<SettingsService>(context, listen: false);
    printer = Provider.of<PrinterService>(context, listen: false);
    super.initState();
  }

  Widget pesoSign = const Text(
    "₱",
    style: TextStyle(fontSize: 20),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartService, OrderService>(
      builder: (context, cartService, orderService, _) {
        double orderAmount = cartService.totalAmount;
        int tenderAmount = cartService.tenderAmount;
        Discount? discount =
            cartService.coupon?.discount ?? cartService.discount;
        double discountAmount = 0;
        if (discount != null) {
          if (discount.type == DiscountType.fixed) {
            discountAmount = discount.value.toDouble();
          } else {
            discountAmount =
                roundDouble(orderAmount * (discount.value / 100), 2);
          }
        }
        double grandTotal = orderAmount - discountAmount;
        if (grandTotal < 0) {
          grandTotal = 0;
        }
        double paymentChange = tenderAmount - grandTotal;
        bool shouldPay = tenderAmount == 0 && grandTotal > 0;
        Color actionColor = cartService.hasItem ? Colors.white : Colors.grey;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            title: cartService.currentOrder != null
                ? Text(
                    "#${(cartService.currentOrder!.id).toString().padLeft(6, '0')}")
                : const Text(""),
            actions: [
              Row(
                children: [
                  for (int i = 0; i < cartService.onholds.length; i++)
                    Builder(
                      builder: (context) {
                        Order order = cartService.onholds[i];
                        bool active = cartService.currentOrder?.id == order.id;
                        return OutlinedButton(
                          onPressed: () {
                            cartService.restoreOrder(order);
                          },
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white, width: active ? 3 : 1),
                              minimumSize: const Size.square(35),
                              shape: const CircleBorder()),
                          child: Text(
                            "${i + 1}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: active ? FontWeight.bold : null),
                          ),
                        );
                      },
                    ),
                  const SizedBox(
                    width: 20,
                  ),
                  OutlinedButton(
                    onPressed: cartService.hasItem
                        ? () {
                            showLoading(context);
                            orderService
                                .createOrder(
                                    cartService.items,
                                    cartService.totalAmount,
                                    grandTotal,
                                    discount,
                                    tenderAmount,
                                    cartService.coupon,
                                    true)
                                .then((order) async {
                              Navigator.of(context).pop();
                              await cartService.holdTransaction(order!);
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: actionColor)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.back_hand_outlined,
                          color: actionColor,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Hold",
                          style: TextStyle(color: actionColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  OutlinedButton(
                    onPressed: cartService.items.isEmpty
                        ? null
                        : () => confirmCancellation(context, cartService),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: actionColor)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: actionColor,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Cancel",
                          style: TextStyle(color: actionColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: cartService.hasItem
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: cartService.items.length,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var item = cartService.items[index];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: SwipeActionCell(
                                      controller: swipeController,
                                      key: ObjectKey(item),
                                      index: index,
                                      fullSwipeFactor: 0.3,
                                      trailingActions: [
                                        SwipeAction(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                            ),
                                            forceAlignmentToBoundary: true,
                                            performsFirstActionWithFullSwipe:
                                                true,
                                            onTap: (CompletionHandler
                                                handler) async {
                                              await handler(true);
                                              cartService.removeItem(item);
                                            },
                                            color: Colors.red),
                                      ],
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: CartItemCard(
                                          index,
                                          item,
                                          onQtyChange: (value) {
                                            if (value > 0) {
                                              item.quantity = value;
                                              cartService.updateQuantity(
                                                  item, value);
                                              return true;
                                            } else {
                                              confirmAndRemove(
                                                  cartService, item);
                                            }
                                            return false;
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                  height: 3,
                                  indent: 5,
                                  endIndent: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              MdiIcons.cartOutline,
                              size: 100,
                              color: Colors.grey,
                            ),
                            Text(
                              "No Items",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
              ),
              Material(
                elevation: 10,
                child: SizedBox(
                    width: 400,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                InvoiceLine(
                                    label: "Order Amount",
                                    amount: roundDouble(orderAmount)),
                                Builder(builder: (context) {
                                  String str = "Discounts";
                                  if (cartService.coupon != null) {
                                    str +=
                                        " (${cartService.coupon?.description})";
                                  } else if (discount != null &&
                                      discount.type == DiscountType.rate &&
                                      discount.value != 0) {
                                    str += " (${discount.value}%)";
                                  }
                                  return InvoiceLine(
                                      label: str,
                                      amount: roundDouble(discountAmount));
                                }),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Grand Total",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: settings.primaryColor),
                                    ),
                                    Row(
                                      children: [
                                        pesoSign,
                                        Text(
                                          " ${roundDouble(grandTotal, 2)}",
                                          style: TextStyle(
                                              fontSize: 30,
                                              color: settings.primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(),
                                InvoiceLine(
                                    label: "Tendered",
                                    amount: tenderAmount.toDouble()),
                                InvoiceLine(
                                    label: "Change",
                                    amount: roundDouble(paymentChange)),
                              ],
                            ),
                          ),
                          Expanded(
                              child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: const [],
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  onPressed: cartService.hasItem &&
                                          cartService.coupon == null
                                      ? () {
                                          pushHeroDialog(DiscountDialog(
                                            initialValue: discount,
                                            onComplete: (discount) {
                                              cartService.setDiscount(discount);
                                            },
                                          ));
                                        }
                                      : null,
                                  child: Row(
                                    children: const [
                                      Icon(Icons.discount_outlined),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("Discounts"),
                                    ],
                                  )),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  onPressed: cartService.hasItem
                                      ? () {
                                          pushHeroDialog(CouponDialog(
                                              value: cartService.coupon,
                                              onComplete: (code) {
                                                showLoading(context);

                                                cartService
                                                    .setCoupon(code)
                                                    .then((valid) {
                                                  if (!valid) {
                                                    showToast(
                                                        context,
                                                        const Text(
                                                            "Invalid coupon!"));
                                                  }
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              onRemove: () {
                                                cartService.setCoupon(null);
                                                Navigator.of(context).pop();
                                              }));
                                        }
                                      : null,
                                  child: Row(
                                    children: const [
                                      Icon(MdiIcons.ticketOutline),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("Coupon"),
                                    ],
                                  )),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  onPressed: tenderAmount == 0
                                      ? null
                                      : () {
                                          cartService.resetPayment();
                                        },
                                  child: Row(
                                    children: const [
                                      Icon(MdiIcons.cancel),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("Void Payment"),
                                    ],
                                  ))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: const RoundedRectangleBorder()),
                            onPressed: cartService.items.isEmpty
                                ? null
                                : () {
                                    if (shouldPay) {
                                      Navigator.of(context).push(DialogRoute(
                                          context: context,
                                          builder: (context) {
                                            return TenderDialog(
                                              grandTotal,
                                              onTender: (double value) {
                                                cartService.setTenderAmount(
                                                    value.toInt());
                                                Navigator.of(context).pop();
                                              },
                                            );
                                          }));

                                      return;
                                    }
                                    showLoading(context);
                                    orderService
                                        .createOrder(
                                            cartService.items,
                                            cartService.totalAmount,
                                            grandTotal,
                                            discount,
                                            tenderAmount,
                                            cartService.coupon)
                                        .then((order) {
                                      if (order != null) {
                                        printer.printReceipt(order);

                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                "/home", (route) => false);
                                        cartService.completeTrasaction();
                                        pushHeroDialog(
                                            OrderPlacedDialog(
                                                order: order,
                                                tenderAmount:
                                                    tenderAmount.toDouble(),
                                                changeAmount: paymentChange),
                                            false);
                                      }
                                    });
                                  },
                            child: Text(
                              shouldPay
                                  ? "Pay (₱$grandTotal)"
                                  : "Done - Send Order",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )
                        ])),
              )
            ],
          ),
        );
      },
    );
  }

  void confirmAndRemove(CartService cart, CartItem item) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text("Do you want to remove this item?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    cart.removeItem(item);
                    Navigator.of(context).pop();
                    showToast(context, const Text("Item deleted!"));
                  },
                  child: const Text("Yes")),
            ],
          );
        });
  }
}
