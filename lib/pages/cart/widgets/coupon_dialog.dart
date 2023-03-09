import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve_lib/model/coupon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CouponDialog extends StatefulWidget {
  final Coupon? value;
  final ValueSetter<String> onComplete;
  final VoidCallback? onRemove;
  const CouponDialog(
      {super.key, this.value, required this.onComplete, this.onRemove});

  @override
  State<CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<CouponDialog> {
  late TextEditingController _codeController;
  String value = "";

  @override
  void initState() {
    value = widget.value?.code ?? '';
    _codeController = TextEditingController(text: value);
    _codeController.addListener(() {
      setState(() {
        value = _codeController.text;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "coupon",
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(MdiIcons.ticketOutline),
                SizedBox(
                  width: 5,
                ),
                Text("Add Coupon"),
              ],
            ),
            TextField(
              controller: _codeController,
              inputFormatters: [
                UpperCaseTextFormatter(),
              ],
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                icon: const Icon(MdiIcons.text),
                hintText: "Coupon Code",
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                suffixIcon: IconButton(
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  onPressed: _codeController.clear,
                  icon: const Icon(Icons.clear),
                ),
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
                if (widget.value != null) ...[
                  OutlinedButton(
                      onPressed: () {
                        widget.onRemove?.call();
                      },
                      child: const Text("Remove")),
                  const SizedBox(
                    width: 10,
                  ),
                ],
                Expanded(
                    child: ElevatedButton(
                        onPressed: _codeController.text.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                widget.onComplete(_codeController.text);
                              },
                        child: const Text("Ok")))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
