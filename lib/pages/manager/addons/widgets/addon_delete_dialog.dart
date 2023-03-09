import 'package:better_serve/services/app_service.dart';
import 'package:better_serve_lib/model/addon.dart';
import 'package:better_serve/utils/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddonDeleteDialog extends StatefulWidget {
  final List<Addon> addons;
  final VoidCallback callback;
  const AddonDeleteDialog(this.addons, this.callback, {super.key});

  @override
  State<AddonDeleteDialog> createState() => _AddonDeleteDialogState();
}

class _AddonDeleteDialogState extends State<AddonDeleteDialog> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    List<Addon> addons = widget.addons;
    return Consumer<AppService>(builder: (context, appService, _) {
      return AlertDialog(
        title: const Text("Delete Addons"),
        content:
            Text("Are you sure you want to delete ${addons.length} addons(s)?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: deleting
                  ? null
                  : () {
                      setState(() {
                        deleting = true;
                      });
                      appService.deleteAddons(addons).then((value) {
                        if (value != null) {
                          //  show error
                        } else {
                          showToast(
                              context, Text("${addons.length} Addons deleted"));
                          Navigator.of(context).pop();
                          widget.callback();
                        }
                      });
                    },
              child: deleting
                  ? const SizedBox(
                      width: 15, height: 15, child: CircularProgressIndicator())
                  : const Text("Yes"))
        ],
      );
    });
  }
}
