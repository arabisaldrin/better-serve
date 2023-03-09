import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/addon_card.dart';
import 'widgets/addon_delete_dialog.dart';
import 'widgets/addon_form_dialog.dart';

class AddonsPage extends StatefulWidget {
  const AddonsPage({super.key});

  @override
  State<AddonsPage> createState() => _AddonsPageState();
}

class _AddonsPageState extends State<AddonsPage> {
  List<Addon> selected = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, appService, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            AnimatedCrossFade(
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
                            "${appService.addons.length} Addons",
                            style: const TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Hero(
                        tag: "addon_new",
                        child: ElevatedButton(
                            onPressed: () {
                              pushHeroDialog(const AddonFormDialog());
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
                            "${selected.length}/${appService.addons.length} Selected",
                            style: const TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.redAccent)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddonDeleteDialog(selected, () {
                                setState(() {
                                  selected.clear();
                                });
                              });
                            },
                          );
                        },
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
                duration: const Duration(milliseconds: 200)),
            const Divider(
              height: 5,
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                width: double.infinity,
                child: appService.addons.isNotEmpty
                    ? Wrap(
                        children: [
                          for (Addon addon in appService.addons)
                            addonWidget(addon)
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/food.png",
                            width: 200,
                            opacity: const AlwaysStoppedAnimation(100),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Add your first addon",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Tap '+ Add' button to add addon to your inventory",
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          )
                        ],
                      ),
              ),
            )
          ],
        ),
      );
    });
  }

  Widget addonWidget(Addon addon) {
    return Hero(
        tag: "addon_${addon.id}",
        child: AddonCard(
          key: ObjectKey("${addon.id}_${selected.contains(addon)}"),
          addon,
          isActive: selected.contains(addon),
          onSelectionChanged: (bool long) {
            setState(() {
              selected.add(addon);
            });
          },
          onTap: () {
            bool isActive = selected.contains(addon);
            if (selected.isNotEmpty) {
              setState(() {
                if (isActive) {
                  selected.remove(addon);
                  isActive = false;
                } else {
                  selected.add(addon);
                  isActive = true;
                }
              });
            } else {
              pushHeroDialog(AddonFormDialog(addon: addon));
            }
            return isActive;
          },
        ));
  }
}
