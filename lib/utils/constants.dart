import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
String publicPath(String? path) {
  return "${supabase.storageUrl}/object/public${path ?? ''}";
}

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}

class NavigatorKeys {
  static final GlobalKey<NavigatorState> primary = GlobalKey();
  static final GlobalKey<NavigatorState> manager = GlobalKey();
}

BuildContext get primaryContext => NavigatorKeys.primary.currentContext!;
BuildContext get managerContext => NavigatorKeys.manager.currentContext!;

const List<Color> orderStatusColor = [
  Colors.orange, // pending
  Colors.blue, // processing
  Colors.green, //  ready
];

extension DarkMode on BuildContext {
  /// is dark mode currently enabled?
  bool get isDarkMode {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark;
  }
}
