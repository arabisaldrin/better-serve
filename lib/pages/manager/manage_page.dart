// ignore_for_file: prefer_const_constructors

import 'package:better_serve/components/route_builder/fade_route.dart';
import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/components/auth_required_state.dart';
import 'package:better_serve/components/navigation.dart';
import 'package:better_serve/pages/manager/dashboard/dashboard_page.dart';
import 'package:better_serve/pages/manager/addons/addons_page.dart';
import 'package:better_serve/pages/manager/media/media_page.dart';
import 'package:better_serve/pages/manager/products/products_page.dart';
import 'package:better_serve/pages/manager/categories/categories_page.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ManagerPageState();
}

class _ManagerPageState extends AuthRequiredState<ManagerPage> {
  late User? user;

  @override
  void onAuthenticated(Session session) {
    user = session.user;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppService>(builder: (context, app, _) {
      return WillPopScope(
        onWillPop: () async {
          final shouldPop =
              await NavigatorKeys.manager.currentState?.maybePop();

          return shouldPop == null ? true : !shouldPop;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  "assets/icons/better_serve_logo.png",
                  width: 30,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text("Better Serve"),
              ],
            ),
          ),
          drawer: DrawerNavigation((index) {
            app.setPage(index);
          }, user),
          body: Navigator(
            key: NavigatorKeys.manager,
            initialRoute: "dashboard",
            onGenerateRoute: (settings) {
              Widget? widget = _routeBuilders[settings.name]!(context);

              if (settings.name == "products") {
                dynamic args = settings.arguments;
                if (args != null) {
                  widget = ProductsPage(category: args["category"]);
                }
              }

              return FadeRoute(
                  widget: Material(
                child: widget,
              ));
            },
          ),
        ),
      );
    });
  }

  Map<String, WidgetBuilder> get _routeBuilders {
    return {
      'dashboard': (context) => DashboardPage(),
      'products': (context) => ProductsPage(),
      'categories': (context) => CategoriesPage(),
      'addons': (context) => AddonsPage(),
      'media': (context) => MediaPage(),
    };
  }
}
