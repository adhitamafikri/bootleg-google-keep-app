import 'package:bootleg_google_keep_app/utils/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  final value = await showGenericDialog<bool>(
      context: context,
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      optionsBuilder: () => {
            'Cancel': false,
            'Logout': true,
          });

  return value ?? false;
}
