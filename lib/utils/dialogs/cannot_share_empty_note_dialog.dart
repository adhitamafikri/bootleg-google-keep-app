import 'package:flutter/material.dart';
import 'package:bootleg_google_keep_app/utils/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: "Share Not",
      content: "Cannot share an empty note",
      optionsBuilder: () => {'OK': null});
}
