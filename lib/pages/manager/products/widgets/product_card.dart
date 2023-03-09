import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/product.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isActive;
  final bool Function() onTap;
  final ValueChanged<bool> onSelectionChanged;
  const ProductCard(this.product,
      {super.key,
      required this.isActive,
      required this.onTap,
      required this.onSelectionChanged});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isActive = false;
  @override
  void initState() {
    isActive = widget.isActive;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    isActive = widget.isActive;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Product item = widget.product;
    return Consumer<SettingsService>(builder: (context, settings, _) {
      return Hero(
          tag: "product_${item.id}",
          child: SizedBox(
            child: Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent,
              elevation: isActive ? 10 : 5,
              child: Container(
                constraints: const BoxConstraints(
                    minWidth: 150, maxWidth: 150, maxHeight: 150),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: isActive
                            ? settings.primaryColor
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        fadeInDuration: const Duration(milliseconds: 100),
                        fadeOutDuration: const Duration(milliseconds: 100),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Container(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: settings.logo)),
                                )),
                        imageUrl: publicPath(item.imgPath),
                        errorWidget: (context, url, error) {
                          return const Center(
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onLongPress: () {
                            setState(() {
                              isActive = true;
                            });
                            widget.onSelectionChanged(isActive);
                          },
                          onTap: () {
                            setState(() {
                              isActive = widget.onTap();
                            });
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
                                          colors: [
                                        Colors.black,
                                        Colors.transparent
                                      ],
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    opt.value,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    "₱${opt.price}",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                      ),
                      if (isActive)
                        IgnorePointer(
                            child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: settings.primaryColor.withAlpha(50),
                          child: const Icon(
                            Icons.check,
                            size: 50,
                            color: Colors.white,
                          ),
                        ))
                    ],
                  ),
                ),
              ),
            ),
          ));
    });
  }
}
