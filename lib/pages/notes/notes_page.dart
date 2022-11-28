import 'dart:developer';

import 'package:bootleg_google_keep_app/constants/routes.dart';
import 'package:bootleg_google_keep_app/pages/notes/notes_list_view.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_service.dart';
import 'package:bootleg_google_keep_app/services/notes/notes_service.dart';
import 'package:bootleg_google_keep_app/utils/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';

import '../../enums/menu_action.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes'), actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add)),
        PopupMenuButton<MenuAction>(
          onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogoutDialog(context);

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
      body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _notesService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allNotes =
                                snapshot.data as List<NotesDatabase>;
                            log('Your notes: ${allNotes}');
                            return NotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _notesService.deleteNote(id: note.id);
                              },
                              onTap: (note) async {
                                Navigator.of(context).pushNamed(updateNoteRoute,
                                    arguments: note);
                              },
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        default:
                          return const CircularProgressIndicator();
                      }
                    });
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
