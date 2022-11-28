import 'package:bootleg_google_keep_app/utils/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
      context: context,
      title: 'An error occurred',
      content: text,
      optionsBuilder: () => {
            'OK': null,
          });
}
