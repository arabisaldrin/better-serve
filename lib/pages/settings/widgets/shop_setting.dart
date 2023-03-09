import 'package:better_serve/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopSetting extends StatefulWidget {
  const ShopSetting({super.key});

  @override
  State<ShopSetting> createState() => _ShopSettingState();
}

class _ShopSettingState extends State<ShopSetting> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(builder: (context, settings, _) {
      return SingleChildScrollView(
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Product Card",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  settings.set("shop_show_price", !settings.showPrice);
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: settings.showPrice,
                      onChanged: (val) {
                        settings.set("shop_show_price", val);
                      },
                    ),
                    const Text("Show Price"),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  settings.set("shop_show_quick_view", !settings.showQuickView);
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: settings.showQuickView,
                      onChanged: (val) {
                        settings.set("shop_show_quick_view", val);
                      },
                    ),
                    const Text("Cart Quick View Panel"),
                  ],
                ),
              ),
            ],
          ),
        )),
      );
    });
  }
}
