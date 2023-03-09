import 'package:better_serve_lib/model/order.dart';
import 'package:better_serve/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'widgets/pending_order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(builder: (context, orderService, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text("(${orderService.orders.length}) Orders"),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: orderService.onGoingOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          MdiIcons.clipboardListOutline,
                          size: 100,
                          color: Colors.grey,
                        ),
                        Text(
                          "No ongoing orders right now",
                          style: TextStyle(fontSize: 30, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.count(
                    childAspectRatio: 1.8,
                    crossAxisCount: 3,
                    // crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (Order order in orderService.onGoingOrders)
                        PendingOrderCard(order: order)
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
