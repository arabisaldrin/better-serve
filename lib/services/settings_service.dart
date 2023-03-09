import 'dart:collection';

import 'package:better_serve_lib/model/attribute.dart';
import 'package:better_serve_lib/model/variation.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve_lib/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SettingsService settings = SettingsService.instance;

class SettingsService with ChangeNotifier {
  final Map<String, dynamic> _settings = HashMap();

  static SettingsService? _instance;

  static SettingsService get instance {
    _instance ??= SettingsService();
    return _instance!;
  }

  Future get load async {
    PostgrestResponse res = await supabase.from("settings").select().execute();

    if (res.error != null && res.status != 406) {
      return false;
    }

    for (dynamic item in res.data as List<dynamic>) {
      _settings.putIfAbsent(item["name"], () => item["value"]["value"]);
    }

    return true;
  }

  Color get primaryColor => _settings.containsKey("primary_color")
      ? Pallete.hexToColor(_settings["primary_color"])
      : Colors.transparent;

  String get companyName => getValue("company_name", "Better Serve");

  String get companyAddress => getValue("company_address", "");

  String get vatRegistration => getValue("vat_registration", "");

  ImageProvider get logo => getValue("logo_url",
      "/images/better_serve_logo.png", (v) => NetworkImage(publicPath(v)));

  int get viewGridSize => getValue("view_grid_size", 6);

  String get printerName => getValue("printer_name", "MTP-2");

  String get receiptLogoPath => getValue(
      "receipt_logo", "/images/receipt_logo.png", (v) => publicPath(v));

  bool get useWhite => useWhiteForeground(primaryColor);

  bool get showPrice => getValue("shop_show_price", false);
  bool get showQuickView => getValue("shop_show_quick_view", false);

  dynamic getValue(String key, dynamic def, [ValueChanged? transformer]) {
    transformer = transformer ??= (v) => v;
    dynamic value = _settings.containsKey(key) ? _settings[key] : def;
    return transformer.call(value);
  }

  List<Variation> get variationTempalates {
    if (_settings.containsKey("variation_templates")) {
      List<dynamic> s = _settings["variation_templates"];
      return s.map((e) {
        return Variation.fromJson(e);
      }).toList();
    }
    return List.empty(growable: true);
  }

  List<Attribute> get attributeTemplates {
    if (_settings.containsKey("attribute_templates")) {
      List<dynamic> s = _settings["attribute_templates"];
      return s.map((e) {
        return Attribute.fromJson(e);
      }).toList();
    }
    return List.empty(growable: true);
  }

  void setPrimaryColor(Color color) {
    set("primary_color", '#${color.value.toRadixString(16).substring(2)}');
    notifyListeners();
  }

  Future<List<String?>?> save([bool notify = true]) async {
    List<Future<PostgrestResponse<dynamic>>> futures =
        List.empty(growable: true);
    for (int i = 0; i < _settings.entries.length; i++) {
      var entry = _settings.entries.elementAt(i);
      futures.add(supabase.from("settings").upsert({
        "name": entry.key,
        "value": {"value": entry.value}
      }, onConflict: "name").execute());
    }

    List<PostgrestResponse> res = await Future.wait(futures);
    if (res.any((e) => e.hasError)) {
      return res.map((e) => e.error?.message).toList();
    }
    if (notify) notifyListeners();
    return null;
  }

  void set(String key, dynamic value) {
    _settings[key] = value;
    notifyListeners();
  }

  ThemeMode get theme {
    if (_settings.containsKey("app_theme")) {
      switch (_settings["app_theme"]) {
        case "dark":
          return ThemeMode.dark;
        case "light":
          return ThemeMode.light;
        case "system":
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }

  void setViewGridSize(int size) {
    set("view_grid_size", size);
    save(false);
  }

  void setTheme(String value) {
    set("app_theme", value);
    notifyListeners();
  }

  void setPrinter(String? name) {
    set("printer_name", name);
    save(false);
  }
}
