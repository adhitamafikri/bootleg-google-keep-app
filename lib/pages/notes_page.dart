import 'package:bootleg_google_keep_app/constants/routes.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import '../enums/menu_action.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes'), actions: [
        PopupMenuButton<MenuAction>(
          onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);

                if (shouldLogout) {
                  await AuthService.firebase().logout();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }
                break;
            }
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text('Logout'))
            ];
          },
        )
      ]),
      body: Container(),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) async {
  final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('logout'),
          content: const Text('Are you sure you want to to logout?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Logout'))
          ],
        );
      });

  return result ?? false;
}
