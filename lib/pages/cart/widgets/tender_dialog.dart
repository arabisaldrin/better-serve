import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class TenderDialog extends StatefulWidget {
  final double amount;
  final void Function(double value) onTender;
  const TenderDialog(this.amount, {Key? key, required this.onTender})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TenderDialogState();
}

class _TenderDialogState extends State<TenderDialog> {
  String value = "0";

  late SettingsService settings;
  @override
  void initState() {
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "tender",
      width: 390,
      builder: (context, toggleLoadding) {
        return Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 10),
          height: 500,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: const [
                      Icon(
                        MdiIcons.cashRegister,
                        size: 15,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Tender",
                        style: TextStyle(fontSize: 25),
                      )
                    ],
                  ),
                  const Divider(),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: settings.primaryColor),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: value == "0" ? Colors.grey : null),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 7; i <= 9; i++) numKey(i),
                          numKey(const Icon(Icons.backspace), () {
                            setState(() {
                              if (value.isNotEmpty) {
                                value = value.substring(0, value.length - 1);
                                if (value.isEmpty) value = "0";
                              } else {
                                value = "0";
                              }
                            });
                          })
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 4; i <= 6; i++) numKey(i),
                          numKey("+50")
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 1; i <= 3; i++) numKey(i),
                          numKey("+100")
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          numKey("C", () {
                            setState(() {
                              value = "0";
                            });
                          }),
                          numKey(0, null, 2),
                          numKey(
                              const Text(
                                "+500",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ), () {
                            setState(() {
                              value = (int.parse(value) + 1000).toString();
                            });
                          })
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(),
              Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel")),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: int.parse(value.isEmpty ? "0" : value) <
                                    widget.amount
                                ? null
                                : () {
                                    widget.onTender(double.parse(value));
                                  },
                            child: const Text("Tender")),
                      ),
                    ],
                  ))
            ],
          ),
        );
      },
    );
  }

  Widget numKey(dynamic content, [void Function()? action, double size = 1]) {
    double buttonSize = 86;
    return Card(
        child: InkWell(
      onTap: () {
        if (content is int) {
          setState(() {
            if (value == "0") value = "";
            value += content.toString();
          });
        } else if (content is String && action == null) {
          if (content.startsWith("+")) {
            int add = int.parse(content.substring(1));
            setState(() {
              value = (int.parse(value) + add).toString();
            });
          }
        } else {
          action?.call();
        }
      },
      child: Container(
        width: size > 1 ? (buttonSize * size) + (10 * size / 2) : buttonSize,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: content is Widget
            ? content
            : Text(
                content.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
      ),
    ));
  }
}
