import 'package:better_serve/services/printer_service.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'printer_setting_dialog.dart';

class PrinterAction extends StatefulWidget {
  const PrinterAction({super.key});

  @override
  State<PrinterAction> createState() => _PrinterActionState();
}

class _PrinterActionState extends State<PrinterAction> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "printer_settings",
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            pushHeroDialog(const PrinterSettingDialog());
          },
          icon: Consumer<PrinterService>(builder: (context, printer, _) {
            if (printer.isConnected) {
              return const Icon(Icons.print_rounded);
            }
            return const Icon(Icons.print_disabled);
          }),
          splashRadius: 20,
        ),
      ),
    );
  }
}
