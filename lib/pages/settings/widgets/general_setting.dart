import 'package:better_serve/pages/settings/settings_page.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

class GeneralSetting extends StatefulWidget {
  final Null Function(BackSetting view) onFlip;
  const GeneralSetting({super.key, required this.onFlip});

  @override
  State<GeneralSetting> createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  late SettingsService settings;

  @override
  void initState() {
    settings = Provider.of<SettingsService>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Company Profile"),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Company Name"),
                  SizedBox(
                      width: 300,
                      child: TextField(
                        controller:
                            TextEditingController(text: settings.companyName),
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Company Address"),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller:
                          TextEditingController(text: settings.companyAddress),
                      minLines: 2,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        settings.set("company_address", value);
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("VAT Registration"),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller:
                          TextEditingController(text: settings.vatRegistration),
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        settings.set("vat_registration", value);
                      },
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Theme"),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Interface"),
                    SizedBox(
                      width: 300,
                      child: SelectFormField(
                        initialValue: settings.theme.name,
                        items: const [
                          {
                            'value': 'system',
                            'label': 'System',
                            'icon': Icon(Icons.phone_android_rounded),
                          },
                          {
                            'value': 'light',
                            'label': 'Light',
                            'icon': Icon(Icons.light_mode),
                          },
                          {
                            'value': 'dark',
                            'label': 'Dark',
                            'icon': Icon(Icons.dark_mode),
                          },
                        ],
                        onChanged: (value) {
                          settings.setTheme(value);
                        },
                      ),
                    )
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Color",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                          onPressed: () => widget.onFlip(BackSetting.color),
                          child: const Icon(MdiIcons.cursorPointer)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
