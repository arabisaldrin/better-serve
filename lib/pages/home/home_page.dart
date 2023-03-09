import 'package:badges/badges.dart';
import 'package:better_serve/pages/home/widgets/printer_action.dart';
import 'package:better_serve/services/cart_service.dart';
import 'package:better_serve/services/order_service.dart';
import 'package:better_serve/pages/home/shop_page.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int gridSize = 6;

  late SettingsService settings;

  @override
  void initState() {
    settings = Provider.of<SettingsService>(context, listen: false);
    gridSize = settings.viewGridSize;
    if (settings.showQuickView && gridSize >= 8) gridSize = 6;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartService, OrderService>(
        builder: (context, cart, orderService, _) {
      return Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(children: [
            Hero(
              tag: "manager_access",
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    // pushHeroDialog(const ManagerAccessDialog());
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil("/manage", (route) => false);
                  },
                  icon: const Icon(Icons.space_dashboard_outlined),
                  splashRadius: 20,
                ),
              ),
            ),
            const PrinterAction(),
            const SizedBox(
              width: 20,
            ),
            Image.asset(
              "assets/icons/better_serve_logo.png",
              width: 30,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text("Better Serve"),
          ]),
          actions: [
            InkWell(
              customBorder: const CircleBorder(),
              onTap: (() => Navigator.of(context).pushNamed("/orders")),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Badge(
                  badgeContent: Text(
                    orderService.onGoingOrders.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(Icons.format_list_numbered),
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: (() => Navigator.of(context).pushNamed("/cart")),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Badge(
                  badgeContent: Text(
                    cart.itemCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(Icons.shopping_cart),
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        body: ShopPage(gridSize),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: gridSize < (settings.showQuickView ? 6 : 8)
                    ? () {
                        setState(() {
                          gridSize += 1;
                        });
                        settings.setViewGridSize(gridSize);
                      }
                    : null,
                icon: const Icon(Icons.zoom_out)),
            SizedBox(
              width: 5,
              child: Text("$gridSize"),
            ),
            IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: gridSize > (settings.showQuickView ? 4 : 6)
                    ? () {
                        setState(() {
                          gridSize -= 1;
                        });
                        settings.setViewGridSize(gridSize);
                      }
                    : null,
                icon: const Icon(Icons.zoom_in)),
          ]),
        ),
      );
    });
  }
}
