import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve/models/item_action.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttributeSetting extends StatelessWidget {
  final List<Attribute> attributeTemplates;
  final VoidCallback onAdd;
  final Null Function(Attribute attribute, ItemAction action) itemAction;
  const AttributeSetting(this.attributeTemplates,
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
                  "Attributes: ",
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
                if (attributeTemplates.isEmpty) ...[
                  const Text(
                    "No attribute templates",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ] else
                  ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Attribute attr = attributeTemplates[index];
                        return InkWell(
                          onTap: () {
                            itemAction(attr, ItemAction.edit);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.edit_note),
                                    Text(attr.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ))
                                  ],
                                ),
                                Wrap(
                                  spacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    for (AttributeOption option in attr.options)
                                      Chip(
                                        backgroundColor: option.selected
                                            ? settings.primaryColor
                                            : null,
                                        label: Text(option.value,
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
                                        itemAction(attr, ItemAction.delete);
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
                      itemCount: attributeTemplates.length)
                // for (Attribute attr in attributeTemplates)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
