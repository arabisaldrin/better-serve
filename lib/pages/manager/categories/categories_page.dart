import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/model/category.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import 'widgets/category_delete_dialog.dart';
import 'widgets/category_form_dialog.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, appService, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "(${appService.categories.length}) Categories",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Hero(
                  tag: "add_category",
                  child: ElevatedButton(
                      onPressed: () {
                        pushHeroDialog(const CategoryFormDialog());
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          Text("Add"),
                        ],
                      )),
                )
              ],
            ),
            const Divider(
              height: 5,
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: appService.categories.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReorderableTable(
                          header: ReorderableTableRow(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text('Name'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text('Icon'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text('Products Count'),
                                ),
                                Text(''),
                              ]),
                          onReorder: (oldIndex, newIndex) {
                            appService.swapOrder(oldIndex, newIndex);
                          },
                          children: [
                            for (Category category in appService.categories)
                              ReorderableTableRow(
                                  key: ObjectKey(category.id),
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(category.name),
                                    ),
                                    CachedNetworkImage(
                                      width: 20,
                                      imageUrl: publicPath(category.icon),
                                      errorWidget: (context, url, error) {
                                        return const Center(
                                          child: Icon(Icons.error),
                                        );
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          category.productCount.toString(),
                                          textAlign: TextAlign.right,
                                        ),
                                        IconButton(
                                          splashRadius: 20,
                                          onPressed: () {
                                            Navigator.of(managerContext)
                                                .pushReplacementNamed(
                                                    "products",
                                                    arguments: {
                                                  "category": category
                                                });
                                          },
                                          icon: const Icon(
                                            Icons.open_in_new,
                                            size: 15,
                                            color: Colors.blueAccent,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Hero(
                                          tag: "edit_category_${category.id}",
                                          child: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                                splashRadius: 20,
                                                onPressed: () {
                                                  pushHeroDialog(
                                                      CategoryFormDialog(
                                                    category: category,
                                                  ));
                                                },
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                )),
                                          ),
                                        ),
                                        IconButton(
                                            splashRadius: 20,
                                            onPressed: category.productCount > 0
                                                ? null
                                                : () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return CategoryDeleteDialog(
                                                            category);
                                                      },
                                                    );
                                                  },
                                            icon: Icon(
                                              Icons.delete,
                                              color: category.productCount > 0
                                                  ? Colors.grey
                                                  : Colors.redAccent,
                                            )),
                                      ],
                                    )
                                  ])
                          ],
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/menu.png",
                          width: 200,
                          opacity: const AlwaysStoppedAnimation(100),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Add your first category",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Tap '+ Add' button to add product category",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        )
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}
