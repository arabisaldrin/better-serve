import 'package:better_serve/components/category_nav.dart';
import 'package:better_serve/pages/home/widgets/quick_view_panel.dart';
import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/services/cart_service.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import 'widgets/product_card.dart';

class ShopPage extends StatefulWidget {
  final int gridSize;
  const ShopPage(this.gridSize, {Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Category? activeCategory;

  late CartService cart;

  @override
  void initState() {
    cart = Provider.of<CartService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (BuildContext context, appService, _) {
      var products = appService.products;
      var categories =
          appService.categories.where((e) => e.productCount > 0).toList();
      var categoryProducts = activeCategory == null
          ? products
          : products.where((p) => p.category.id == activeCategory!.id);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryNav(categories, onSelect: (Category? category) {
            setState(() {
              activeCategory = category;
            });
            return true;
          }),
          Expanded(
            child: categoryProducts.isNotEmpty
                ? activeCategory == null
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            for (final category in categories) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      width: 20,
                                      imageUrl: publicPath(category.icon),
                                      errorWidget: (context, url, error) {
                                        return const Center(
                                          child: Icon(Icons.error),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      category.name,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              GridView.count(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(10),
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                crossAxisCount: widget.gridSize,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  for (final item in products.where(
                                      (p) => p.categoryId == category.id))
                                    Hero(
                                      tag: "product_${item.id}",
                                      child: ProductCard(
                                        item,
                                        onQuickAdd: () {
                                          quickAdd(item);
                                        },
                                      ),
                                    )
                                ],
                              )
                            ]
                          ],
                        ),
                      )
                    : GridView.count(
                        padding: const EdgeInsets.all(10),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        crossAxisCount: widget.gridSize,
                        children: [
                          for (final item in categoryProducts)
                            Hero(
                              tag: "product_${item.id}",
                              child: ProductCard(
                                item,
                                onQuickAdd: () {
                                  quickAdd(item);
                                },
                              ),
                            )
                        ],
                      )
                : Center(
                    child: appService.loading
                        ? const CircularProgressIndicator()
                        : const Text("No items for the seleted category"),
                  ),
          ),
          if (settings.showQuickView) const QuickViewPanel()
        ],
      );
    });
  }

  void quickAdd(Product item) {
    cart.addItem(CartItem(
        product: item,
        addons: [],
        variation: item.variation,
        attributes: item.attributes,
        quantity: 1));
  }
}
