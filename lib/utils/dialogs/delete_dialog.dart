import 'package:bootleg_google_keep_app/utils/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context) async {
  final value = await showGenericDialog<bool>(
      context: context,
      title: 'Delete Note',
      content: 'Are you sure to delete the note?',
      optionsBuilder: () => {
            'Cancel': false,
            'Delete': true,
          });

  return value ?? false;
}
