import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:better_serve/components/custom_dialog.dart';
import 'package:better_serve/services/cart_service.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/components/hero_dialog_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

List<List<dynamic>> partition(List<dynamic> items, int size) {
  var len = items.length;
  List<List<dynamic>> chunks = [];

  for (var i = 0; i < len; i += size) {
    var end = (i + size < len) ? i + size : len;
    chunks.add(items.sublist(i, end));
  }
  return chunks;
}

extension ListAccesor<T> on List<T> {
  T? get firstOrNull {
    if (isNotEmpty) return first;
    return null;
  }

  T? getFirstOrNull([bool Function(T e)? predicate]) {
    if (predicate == null) {
      return firstOrNull;
    }
    return where(predicate).toList().firstOrNull;
  }
}

pushHeroDialog(Widget child, [bool barrierDismissible = false]) {
  Navigator.of(primaryContext).push(HeroDialogRoute(
      dismissible: barrierDismissible,
      builder: (context) {
        return child;
      }));
}

popHeroDialog() {
  Navigator.of(primaryContext).pop();
}

double roundDouble(double value, [int places = 2]) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> downloadFile(String url, String fileName) async {
  HttpClient httpClient = HttpClient();
  File file;
  String filePath = '';

  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();

  var bytes = await consolidateHttpClientResponseBytes(response);
  filePath = '${await localPath}/$fileName';
  file = File(filePath);
  await file.writeAsBytes(bytes);

  return filePath;
}

Future<String> getBase64Logo(String url, [bool redownload = false]) async {
  String path = "${await localPath}/logo.png";
  File logo = File(path);
  if (!await logo.exists() || redownload) {
    await downloadFile(url, "logo.png");
    logo = File(path);
  }

  final bytes = await logo.readAsBytes();
  ByteData data = bytes.buffer.asByteData();
  List<int> imageBytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  String base64Image = base64Encode(imageBytes);
  return base64Image;
}

void confirmCancellation(BuildContext context, CartService cartService) {
  showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: "Cancel transaction?",
          content:
              "This will cancel the current transaction and will remove all items from the cart.",
          positiveBtnText: "Yes",
          negativeBtnText: "Cancel",
          type: DialogType.error,
          positiveBtnPressed: () {
            cartService.cancelTransaction();
            Navigator.of(context).pop();
          },
        );
      });
}
