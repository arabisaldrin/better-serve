import 'dart:collection';

import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/cupertino.dart';

import '../utils/app_helper.dart';

BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

class PrinterService with ChangeNotifier {
  bool isScanning = false;
  bool isConnected = false;
  BluetoothDevice? device;

  static PrinterService? _instance;

  static PrinterService get instance {
    _instance ??= PrinterService();
    return _instance!;
  }

  PrinterService() {
    initState();
  }

  Future initState() async {
    bluetoothPrint.isScanning.listen((event) {
      isScanning = event;
      notifyListeners();
    });

    bluetoothPrint.state.listen((event) {
      isConnected = event == BluetoothPrint.CONNECTED;
      if (!isConnected) {
        device = null;
      }
      notifyListeners();
    });

    isConnected = (await bluetoothPrint.isConnected) ?? false;
    if (!isConnected) {
      tryConnect(SettingsService.instance.printerName);
    } else {
      await Future.delayed(const Duration(seconds: 10));
      notifyListeners();
    }
  }

  Future tryConnect(String printerName) async {
    bluetoothPrint.scanResults.listen((devices) {
      for (BluetoothDevice d in devices) {
        if (d.name == printerName) {
          bluetoothPrint.stopScan().then((_) {
            isScanning = false;
          });
          bluetoothPrint.connect(d).then((_) async {
            isConnected = true;
            device = d;
            await Future.delayed(const Duration(seconds: 5));
            notifyListeners();
          });
          break;
        }
      }
    });
    await bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
  }

  Future<bool> printReceipt(Order order) async {
    if (!isConnected) {
      return false;
    }
    SettingsService settings = SettingsService.instance;
    LineText lineFeed = LineText(linefeed: 1);
    Map<String, dynamic> config = HashMap();
    List<LineText> lines = List.empty(growable: true);

    String base64Image = await getBase64Logo(settings.receiptLogoPath, true);
    lines.add(LineText(
        type: LineText.TYPE_IMAGE,
        align: LineText.ALIGN_CENTER,
        width: 150,
        content: base64Image,
        linefeed: 1));
    lines.add(lineFeed);
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: settings.companyName,
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(LineText(linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: settings.companyAddress,
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "VAT Reg. ${settings.vatRegistration}",
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(lineFeed);
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Serving #${order.queueNumber}",
        weight: 1,
        fontZoom: 2,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(receiptDivider);
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "${order.orderDate} ${order.orderTime}",
        weight: 0,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    lines.add(receiptDivider);
    lines.add(LineText(linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "Order No. : ${order.id.toString().padLeft(6, '0')}",
        weight: 0,
        linefeed: 1));
    lines.add(receiptDivider);

    for (OrderItem item in order.items) {
      lines.add(receiptLine(
          formatLine(item.productName, item.unitPrice, item.quantity)));
      for (OrderItemAddon addon in item.addons) {
        lines.add(receiptLine(formatLine(" ${addon.name}", addon.price)));
      }
    }
    lines.add(receiptDivider);

    lines.add(receiptLine(formatLine("Total Due", order.orderAmount), 1));
    lines
        .add(receiptLine(formatLine("Discount", -(order.discountAmount ?? 0))));
    lines.add(receiptDivider);
    lines.add(receiptLine(formatLine("Grand Total", order.grandTotal), 1));
    lines.add(receiptLine(formatLine("Payment", order.paymentAmount)));

    int change = order.paymentAmount - order.grandTotal;
    lines.add(receiptLine(formatLine("Change", change)));

    lines.add(lineFeed);
    lines.add(lineFeed);
    lines.add(receiptLine("**CUSTOMER COPY**", 1, true));
    lines.add(lineFeed);
    lines.add(receiptLine("Thanks for Visiting", 0, true));
    lines.add(lineFeed);
    bluetoothPrint.printReceipt(config, lines);

    return true;
  }

  static LineText receiptLine(
    String content, [
    int weight = 0,
    bool center = false,
  ]) =>
      LineText(
          type: LineText.TYPE_TEXT,
          content: content,
          weight: weight,
          align: center ? LineText.ALIGN_CENTER : LineText.ALIGN_LEFT,
          linefeed: 1);

  static LineText get receiptDivider => LineText(
      type: LineText.TYPE_TEXT,
      content: ''.padRight(32, "-"),
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1);

  static String formatLine(String name, num price, [int? qty]) {
    String line = "${qty ?? ''} $name";
    String priceStr = price.toStringAsFixed(2).replaceAll("-", "");
    priceStr = ((price) < 0 ? "($priceStr)" : priceStr);

    int spaces = 32 - (line.length + priceStr.length);

    return line.padRight(line.length + spaces, " ") + priceStr;
  }

  void setConnected(bool bool) {
    isConnected = bool;
    notifyListeners();
  }
}
