import 'package:better_serve/models/item_action.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VariationSetting extends StatelessWidget {
  final List<Variation> variationTempalates;
  final VoidCallback onAdd;
  final Null Function(Variation variation, ItemAction action) itemAction;
  const VariationSetting(this.variationTempalates,
      {super.key, required this.onAdd, required this.itemAction});

  @override
  Widget build(BuildContext context) {
    SettingsService settings =
        Provider.of<SettingsService>(context, listen: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Variation: ",
                  style: TextStyle(fontSize: 15),
                ),
                IconButton(
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    onPressed: onAdd,
                    icon: const Icon(Icons.add))
              ],
            ),
            const Divider(),
            Column(
              children: [
                if (variationTempalates.isEmpty) ...[
                  const Text(
                    "No variation templates",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ] else
                  ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        Variation variation = variationTempalates[index];
                        return InkWell(
                          onTap: () {
                            itemAction(variation, ItemAction.edit);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.edit_note),
                                    Text(variation.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        )),
                                  ],
                                ),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    for (VariationOption option
                                        in variation.options)
                                      Chip(
                                        backgroundColor: option.selected
                                            ? settings.primaryColor
                                            : null,
                                        label: Text(
                                            "${option.value} | ₱${option.price}",
                                            style: TextStyle(
                                              color: option.selected
                                                  ? Colors.white
                                                  : context.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                            )),
                                      ),
                                    const SizedBox(
                                      height: 40,
                                      child: VerticalDivider(),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        itemAction(
                                            variation, ItemAction.delete);
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_outlined,
                                        color: Colors.red,
                                      ),
                                      splashRadius: 20,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: variationTempalates.length)
                // for (Variation variation in variationTempalates)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
