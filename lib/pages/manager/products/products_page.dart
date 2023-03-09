import 'package:better_serve/pages/manager/products/widgets/move_category_dialog.dart';
import 'package:better_serve/pages/manager/products/widgets/product_card.dart';
import 'package:better_serve/pages/manager/products/widgets/product_delete_dialog.dart';
import 'package:better_serve/pages/manager/products/widgets/product_form_dialog.dart';
import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/components/category_nav.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsPage extends StatefulWidget {
  final Category? category;
  const ProductsPage({Key? key, this.category}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> selected = List.empty(growable: true);

  Category? activeCategory;
  int? selectedMoveCategory;
  bool movingItems = true;

  @override
  void initState() {
    activeCategory = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (selected.isNotEmpty) {
          setState(() {
            selected.clear();
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Consumer<AppService>(builder: ((context, appService, _) {
        var products = appService.products;
        var categoryProducts = activeCategory == null
            ? products
            : products.where((p) => p.category.id == activeCategory!.id);
        return Row(
          children: [
            CategoryNav(appService.categories, onSelect: (Category? category) {
              setState(() {
                activeCategory = category;
              });
              return true;
            },
                showAdd: true,
                selectedIndex: widget.category == null
                    ? 0
                    : appService.categories.indexOf(widget.category!) + 1),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: AnimatedCrossFade(
                      firstChild: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.inventory,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${categoryProducts.length} Products",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.info,
                                      size: 14,
                                    ),
                                    Text(
                                        " Tap and hold item to start selection"),
                                  ],
                                )
                              ],
                            ),
                          ),
                          OutlinedButton(
                              onPressed: () {
                                Navigator.of(managerContext)
                                    .pushNamed("categories");
                              },
                              child: const Text("Manage Categories")),
                          const SizedBox(
                            width: 10,
                          ),
                          Hero(
                              tag: "product_new",
                              child: ElevatedButton(
                                  onPressed: () {
                                    pushHeroDialog(ProductFormDialog(
                                        context, null, activeCategory));
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.add),
                                      Text("Add"),
                                    ],
                                  )))
                        ],
                      ),
                      secondChild: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.inventory,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "${selected.length}/${categoryProducts.length} Selected",
                                  style: const TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          ),
                          OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(DialogRoute(
                                    context: context,
                                    builder: (context) {
                                      return MoveCategoryDialog(
                                          items: selected,
                                          onComplete: () {
                                            setState(() {
                                              selected.clear();
                                            });
                                          });
                                    }));
                              },
                              child: const Text("Move to Category")),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.redAccent)),
                              onPressed: () => onDeleteAction(appService),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.delete,
                                    size: 15,
                                  ),
                                  Text("Delete")
                                ],
                              ))
                        ],
                      ),
                      crossFadeState: selected.isEmpty
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300)),
                ),
                const Divider(
                  height: 1,
                ),
                Expanded(
                  child: appService.loading
                      ? const Center(child: CircularProgressIndicator())
                      : categoryProducts.isEmpty
                          ? products.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/food.png",
                                      width: 200,
                                      opacity:
                                          const AlwaysStoppedAnimation(100),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Add your first product",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Tap '+ Add' button to add product to your inventory",
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey),
                                    )
                                  ],
                                )
                              : const Text(
                                  "No product(s) for the selected category",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.grey),
                                )
                          : activeCategory == null
                              ? SizedBox(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (Category category
                                              in appService.categories) ...[
                                            if (products
                                                .where((e) =>
                                                    e.categoryId == category.id)
                                                .isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  category.name,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ),
                                            Wrap(
                                              spacing: 5,
                                              runSpacing: 5,
                                              children: [
                                                for (Product product
                                                    in products.where((e) =>
                                                        e.categoryId ==
                                                        category.id))
                                                  productWidget(product)
                                              ],
                                            )
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(5),
                                  width: double.infinity,
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: [
                                      for (Product product in categoryProducts)
                                        productWidget(product)
                                    ],
                                  ),
                                ),
                ),
              ],
            ))
          ],
        );
      })),
    );
  }

  Widget productWidget(Product product) {
    return ProductCard(
      product,
      isActive: selected.contains(product),
      onSelectionChanged: (bool val) {
        if (val) {
          setState(() {
            selected.add(product);
          });
        }
      },
      onTap: () {
        bool isActive = selected.contains(product);
        if (selected.isNotEmpty) {
          setState(() {
            if (isActive) {
              selected.remove(product);
            } else {
              selected.add(product);
            }
            isActive = !isActive;
          });
        } else {
          pushHeroDialog(ProductFormDialog(context, product, activeCategory));
        }
        return isActive;
      },
    );
  }

  void onDeleteAction(AppService appService) async {
    showDialog(
      context: context,
      builder: (context) {
        return ProductDeleteDialog(selected, () {
          setState(() {
            selected.clear();
          });
        });
      },
    );
  }
}
