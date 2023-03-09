import 'package:better_serve/services/app_service.dart';
import 'package:better_serve/pages/settings/settings_page.dart';
import 'package:better_serve/services/settings_service.dart';
import 'package:better_serve/utils/app_helper.dart';
import 'package:better_serve/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User, Session;

import 'auth_required_state.dart';

class DrawerNavigation extends StatefulWidget {
  final Function onItemTap;
  final User? user;
  const DrawerNavigation(this.onItemTap, this.user, {super.key});

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends AuthRequiredState<DrawerNavigation> {
  List<dynamic> navItems = List.from([
    {"icon": Icons.computer, "name": "Dashboard", "path": "dashboard"},
    {"icon": Icons.store, "name": "Products", "path": "products"},
    {"icon": Icons.category, "name": "Categories", "path": "categories"},
    {"icon": MdiIcons.food, "name": "Addons", "path": "addons"},
    {"icon": Icons.image, "name": "Media", "path": "media"},
  ]);

  User? user;
  late SettingsService settings;
  @override
  void onAuthenticated(Session session) {
    user = session.user!;
    super.onAuthenticated(session);
  }

  @override
  void initState() {
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Consumer<AppService>(
            builder: (BuildContext context, AppService appService, _) {
              var profile = appService.profile;
              return DrawerHeader(
                  decoration: BoxDecoration(
                    color: settings.primaryColor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (profile.avatarUrl != null)
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.deepOrange,
                            child: Text(
                              profile.initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            // backgroundImage:
                            //     NetworkImage(profile.avatarUrl!),
                          ),
                        const SizedBox(height: 5),
                        Text(profile.username,
                            style: TextStyle(
                              color: settings.useWhite
                                  ? Colors.white70
                                  : Colors.black,
                              fontSize: 20,
                            )),
                        Text(user!.email!,
                            style: TextStyle(
                              color: settings.useWhite
                                  ? Colors.white70
                                  : Colors.black,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ));
            },
          ),
          for (var i = 0; i < navItems.length; i++)
            menuItem(navItems[i]["icon"], navItems[i]["name"], () {
              Navigator.of(context).pop();
              Navigator.of(managerContext).pushNamedAndRemoveUntil(
                  navItems[i]["path"], (route) => false);
            }),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.of(context).pop();
                pushHeroDialog(const SettingsPage());
              }),
          const Expanded(child: SizedBox()),
          const Divider(height: 1.0, color: Colors.grey),
          menuItem(Icons.exit_to_app, "Exit", _signOut)
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    Navigator.of(primaryContext)
        .pushNamedAndRemoveUntil("/home", (route) => false);
  }

  Widget menuItem(IconData ic, String text, void Function() onTap) {
    return ListTile(leading: Icon(ic), title: Text(text), onTap: onTap);
  }
}
