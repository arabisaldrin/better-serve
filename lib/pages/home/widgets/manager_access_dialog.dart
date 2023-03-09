import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:flutter/material.dart';

class ManagerAccessDialog extends StatefulWidget {
  const ManagerAccessDialog({super.key});

  @override
  State<ManagerAccessDialog> createState() => _ManagerAccessDialogState();
}

class _ManagerAccessDialogState extends State<ManagerAccessDialog> {
  String password = "";

  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "manager_access",
      width: 300,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  Icon(Icons.login_outlined),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Manager Access Authorization",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const Divider(),
            TextField(
              obscureText: true,
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Key',
                icon: Icon(Icons.security),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const Divider(),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              "/manage", (route) => false);
                          // if (_controller.text == "admin") {}
                        },
                        child: const Text("Ok")))
              ],
            )
          ],
        ),
      ),
    );
  }
}
