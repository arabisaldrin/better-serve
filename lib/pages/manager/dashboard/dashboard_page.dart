import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/services/order_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../models/sale.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late AppService _appService;

  Widget cardLoader = const Expanded(
    child: Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppService, OrderService>(
      builder: (BuildContext context, appService, orderService, _) {
        _appService = appService;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Dashboard"),
                    ],
                  ),
                ),
                const Divider(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: const [
                      Icon(Icons.pie_chart_outline),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Sales Report",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
                FutureBuilder(
                    future: orderService.getSale(),
                    builder:
                        (BuildContext context, AsyncSnapshot<Sale?> snapshot) {
                      Sale? sale = snapshot.data;
                      return Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          summaryCard(
                              Colors.green,
                              Column(children: [
                                cardHeader(
                                  const Icon(
                                    Icons.shopping_cart_checkout,
                                    color: Colors.white,
                                  ),
                                ),
                                snapshot.hasData
                                    ? cardCenterText(
                                        sale!.orderCount.toString())
                                    : cardLoader,
                                const Divider(),
                                cardTitle("Orders")
                              ])),
                          summaryCard(
                              Colors.deepOrange,
                              Column(children: [
                                cardHeader(
                                  const Icon(
                                    Icons.category,
                                    color: Colors.white,
                                  ),
                                ),
                                snapshot.hasData
                                    ? cardCenterText(sale!.itemCount.toString())
                                    : cardLoader,
                                const Divider(),
                                cardTitle("Total Items")
                              ])),
                          summaryCard(
                            Colors.blueAccent,
                            Column(
                              children: [
                                cardHeader(
                                  const Icon(
                                    Icons.bar_chart,
                                    color: Colors.white,
                                  ),
                                ),
                                snapshot.hasData
                                    ? cardCenterText(
                                        "₱${NumberFormat("#,###").format(sale!.totalAmount)}",
                                        20)
                                    : cardLoader,
                                const Divider(),
                                cardTitle("Sales")
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: const [
                      Icon(
                        MdiIcons.formatListChecks,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text("System",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    summaryCard(
                        Colors.brown.shade400,
                        Column(children: [
                          cardHeader(
                            const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                            ),
                          ),
                          cardCenterText(
                              _appService.products.length.toString()),
                          const Divider(),
                          cardTitle("Produts")
                        ])),
                    summaryCard(
                      Colors.pinkAccent,
                      Column(
                        children: [
                          cardHeader(
                            const Icon(
                              Icons.category,
                              color: Colors.white,
                            ),
                          ),
                          cardCenterText(
                              _appService.categories.length.toString()),
                          const Divider(),
                          cardTitle("Categories")
                        ],
                      ),
                    ),
                    summaryCard(
                      Colors.purple,
                      Column(
                        children: [
                          cardHeader(
                            const Icon(
                              MdiIcons.foodVariant,
                              color: Colors.white,
                            ),
                          ),
                          cardCenterText(
                              _appService.addons.length.toString(), 20),
                          const Divider(),
                          cardTitle("Addons")
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget cardHeader(Widget icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [icon],
    );
  }

  Widget cardCenterText(String content, [double size = 40]) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: FittedBox(
          child: Text(content,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ))),
    ));
  }

  Widget cardTitle(String text) {
    return Text(text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
        ));
  }

  Widget summaryCard(Color color, Widget child) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Card(
        elevation: 5,
        color: context.isDarkMode ? color.withAlpha(150) : color,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: child,
        ),
      ),
    );
  }
}
