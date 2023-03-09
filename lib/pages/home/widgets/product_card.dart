import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  final Function()? onQuickAdd;
  const ProductCard(this.item, {Key? key, this.onQuickAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SettingsService settings =
        Provider.of<SettingsService>(context, listen: false);
    return Material(
      elevation: 10,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 100),
          fadeOutDuration: const Duration(milliseconds: 100),
          placeholderFadeInDuration: const Duration(milliseconds: 100),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        image: DecorationImage(image: settings.logo)),
                  )),
          imageUrl: publicPath(item.imgPath),
          errorWidget: (context, url, error) {
            return const Center(
              child: Icon(Icons.error),
            );
          },
        ),
        InkWell(
          onTap: () {
            // pushHeroDialog(OrderItemDialog(item));
            onQuickAdd?.call();
          },
          child: SizedBox(
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (settings.showPrice)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                          Colors.transparent,
                          Colors.black,
                        ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: item.variation != null
                          ? [
                              for (VariationOption opt
                                  in item.variation!.options)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      opt.value,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      "₱${opt.price}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    )
                                  ],
                                )
                            ]
                          : [
                              Text(
                                "₱${item.basePrice}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              )
                            ],
                    ),
                  )
              ],
            ),
          ),
        ),
        // Positioned(
        //   right: 0,
        //   bottom: 0,
        //   child: ElevatedButton(
        //       onPressed: onQuickAdd,
        //       style: ElevatedButton.styleFrom(
        //         shape: const CircleBorder(),
        //       ),
        //       child: const Icon(Icons.add)),
        // )
      ]),
    );
  }
}
