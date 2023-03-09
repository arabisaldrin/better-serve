import 'package:better_serve/components/num_spinner.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve_lib/model/discount.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DiscountDialog extends StatefulWidget {
  final ValueChanged<Discount> onComplete;
  final Discount? initialValue;
  const DiscountDialog(
      {super.key, required this.onComplete, this.initialValue});

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  DiscountType type = DiscountType.fixed;
  int value = 0;

  @override
  void initState() {
    if (widget.initialValue != null) {
      type = widget.initialValue!.type;
      value = widget.initialValue!.value;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "discount",
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.discount_outlined),
                  SizedBox(
                    width: 5,
                  ),
                  Text("Add Discount"),
                ],
              ),
              const Divider(),
              Transform.scale(
                scale: 1.5,
                child: NumSpinner(
                  value,
                  (v) {
                    value = v;
                    return true;
                  },
                  minValue: 0,
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const Text("Discount Type"),
                  Expanded(
                    child: RadioListTile(
                      title: Row(
                        children: const [
                          Icon(
                            MdiIcons.currencyPhp,
                            size: 15,
                          ),
                          Text(" Fixed"),
                        ],
                      ),
                      value: DiscountType.fixed,
                      groupValue: type,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onChanged: (val) {
                        setState(() {
                          type = val!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: Row(
                        children: const [
                          Icon(
                            MdiIcons.percent,
                            size: 18,
                          ),
                          Text(" Rate"),
                        ],
                      ),
                      value: DiscountType.rate,
                      groupValue: type,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onChanged: (val) {
                        setState(() {
                          type = val!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const Divider(),
              SizedBox(
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        numKey("C", () {
                          setState(() {
                            value = 0;
                          });
                        }),
                        numKey("+5"),
                        numKey("+10"),
                        numKey("+20"),
                        numKey("+40"),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      children: [
                        numKey(5),
                        numKey(10),
                        numKey(30),
                        numKey(50),
                        numKey(100),
                      ],
                    ))
                  ],
                ),
              ),
              const Divider(),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close")),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            widget.onComplete(Discount(type, value));
                            Navigator.of(context).pop();
                          },
                          child: const Text("Ok")))
                ],
              ),
            ]),
      ),
    );
  }

  Widget numKey(dynamic content, [void Function()? action, double size = 1]) {
    return Expanded(
      child: Card(
          child: InkWell(
        onTap: () {
          if (action != null) {
            action.call();
            return;
          }
          if (content is int) {
            setState(() {
              value = content;
            });
          } else if (content.startsWith("+")) {
            int add = int.parse(content.substring(1));
            setState(() {
              value += add;
            });
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: content is Widget
              ? content
              : Text(
                  content.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
      )),
    );
  }
}
