import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/addon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddonForm extends StatefulWidget {
  final List<Addon>? selected;
  final Function(List<Addon>? result) onComplete;
  const AddonForm(
      {super.key, required this.selected, required this.onComplete});

  @override
  State<AddonForm> createState() => _AddonFormState();
}

class _AddonFormState extends State<AddonForm> {
  List<Addon> selectedAddons = List.empty(growable: true);
  late SettingsService settings;
  @override
  void initState() {
    if (widget.selected != null) {
      selectedAddons = widget.selected!;
    }
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, appService, _) {
      return DialogPane(
        tag: "_",
        width: 500,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.add),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Select Addon")
                  ],
                ),
                const Divider(),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (Addon addon in appService.addons)
                      Card(
                        clipBehavior: Clip.hardEdge,
                        elevation: 3,
                        margin: EdgeInsets.zero,
                        // borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              int index = selectedAddons
                                  .indexWhere((e) => e.id == addon.id);
                              if (index != -1) {
                                selectedAddons.removeAt(index);
                              } else {
                                selectedAddons.add(addon);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
                            constraints: const BoxConstraints(
                              maxWidth: 110,
                              maxHeight: 110,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CachedNetworkImage(
                                  progressIndicatorBuilder: (context, url,
                                          downloadProgress) =>
                                      Container(
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: 100,
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: settings.logo)),
                                          )),
                                  imageUrl: publicPath(addon.imgPath),
                                  errorWidget: (context, url, error) {
                                    return const Icon(
                                      Icons.error,
                                      size: 30,
                                    );
                                  },
                                  fit: BoxFit.fill,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        addon.name,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        "₱${addon.price}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                if (selectedAddons.getFirstOrNull(
                                      (e) => e.id == addon.id,
                                    ) !=
                                    null)
                                  Container(
                                    color: settings.primaryColor.withAlpha(100),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.check,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onComplete(selectedAddons);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.check),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Ok",
                        ),
                      ],
                    ),
                  ),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       widget.onComplete(selectedAddons);
                  //     },
                  //     child: Row(
                  //       children: [
                  //         const Icon(Icons.check),
                  //         Text("Done (${selectedAddons.length})")
                  //       ],
                  //     ))
                ]),
              ]),
        ),
      );
    });
  }
}
