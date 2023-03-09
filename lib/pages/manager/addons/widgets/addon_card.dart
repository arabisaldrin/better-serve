import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddonCard extends StatefulWidget {
  final Addon addon;
  final bool isActive;
  final bool Function() onTap;
  final ValueChanged<bool> onSelectionChanged;
  const AddonCard(this.addon,
      {super.key,
      required this.isActive,
      required this.onTap,
      required this.onSelectionChanged});

  @override
  State<AddonCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<AddonCard> {
  bool isActive = false;

  late SettingsService settings;

  @override
  void initState() {
    isActive = widget.isActive;
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Addon addon = widget.addon;
    return SizedBox(
      child: Card(
        // borderRadius: BorderRadius.circular(10),
        elevation: isActive ? 5 : 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            constraints: const BoxConstraints(
                minWidth: 150, maxWidth: 150, maxHeight: 150),
            decoration: BoxDecoration(
                border: Border.all(
                    color:
                        isActive ? settings.primaryColor : Colors.transparent),
                borderRadius: BorderRadius.circular(5)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 100),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholderFadeInDuration:
                        const Duration(milliseconds: 100),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: settings.logo)),
                            )),
                    imageUrl: publicPath(addon.imgPath),
                    errorWidget: (context, url, error) {
                      return const Center(
                        child: Icon(Icons.error),
                      );
                    },
                  ),
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
                            child: Text(
                              addon.name,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "₱${addon.price.toString()}",
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w700),
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
    );
  }
}
