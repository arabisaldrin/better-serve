import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/components/splash.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/services/order_service.dart';
import 'package:better_serve/pages/cart/cart_page.dart';
import 'package:better_serve/pages/login_page.dart';
import 'package:better_serve/pages/manager/manage_page.dart';
import 'package:better_serve/pages/home/home_page.dart';
import 'package:better_serve/pages/orders/orders_page.dart';
import 'package:better_serve/pages/splash_page.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:better_serve/services/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'services/cart_service.dart';
import 'services/media_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  String? supbaseAnonKey = dotenv.env['SUPABASE_ANON'];

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supbaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => AppService(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => CartService(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => OrderService(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => MediaService(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => SettingsService.instance,
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => PrinterService.instance,
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return FutureBuilder(
            future: SettingsService.instance.load,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Consumer<SettingsService>(
                    builder: (context, settings, _) {
                  return MaterialApp(
                    useInheritedMediaQuery: true,
                    title: settings.companyName,
                    theme: ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: settings.primaryColor,
                      ),
                      checkboxTheme: CheckboxThemeData(
                        fillColor:
                            MaterialStateProperty.all(settings.primaryColor),
                      ),
                    ),
                    darkTheme: ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: settings.primaryColor,
                        brightness: Brightness.dark,
                      ),
                      checkboxTheme: CheckboxThemeData(
                        fillColor:
                            MaterialStateProperty.all(settings.primaryColor),
                      ),
                    ),
                    themeMode: settings.theme,
                    initialRoute: '/',
                    navigatorKey: NavigatorKeys.primary,
                    routes: <String, WidgetBuilder>{
                      '/': (_) => const SplashPage(),
                      '/login': (_) => const LoginPage(),
                      '/home': (_) => const HomePage(),
                      '/manage': (_) => const ManagerPage(),
                      '/orders': (_) => const OrdersPage(),
                      '/cart': (_) => const CartPage()
                    },
                  );
                });
              }
              return MaterialApp(builder: (context, child) {
                return const Splash();
              });
            },
          );
        },
      ),
    );
  }
}
