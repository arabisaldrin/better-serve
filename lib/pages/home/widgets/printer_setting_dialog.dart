import 'package:better_serve/services/printer_service.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrinterSettingDialog extends StatefulWidget {
  const PrinterSettingDialog({super.key});

  @override
  State<PrinterSettingDialog> createState() => _PrinterSettingDialogState();
}

class _PrinterSettingDialogState extends State<PrinterSettingDialog> {
  final PrinterService _pritner = PrinterService.instance;

  @override
  void initState() {
    if (!_pritner.isScanning) {
      bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    }
    super.initState();
  }

  @override
  void dispose() {
    bluetoothPrint.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "printer_setting",
      width: 400,
      maxHeight: 400,
      builder: (context, toggleLoadding) {
        return Padding(
          padding: const EdgeInsets.all(5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(
              children: const [
                Icon(Icons.print_rounded),
                SizedBox(width: 5),
                Text("Select Printer"),
              ],
            ),
            const Divider(),
            Consumer2<PrinterService, SettingsService>(
                builder: (context, printer, settings, _) {
              return StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                builder: (c, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return SingleChildScrollView(
                      child: Column(
                        children:
                            snapshot.data!.where((e) => e.type == 3).map((d) {
                          return ListTile(
                            title: Text("${d.name}"),
                            subtitle: Text(d.address!),
                            onTap: () async {
                              toggleLoadding();
                              printer.setConnected(true);
                              settings.setPrinter(d.name);
                              bluetoothPrint
                                  .connect(d)
                                  .then((value) => Navigator.of(context).pop());
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return const Text("Scanning...");
                },
              );
            })
          ]),
        );
      },
    );
  }
}
