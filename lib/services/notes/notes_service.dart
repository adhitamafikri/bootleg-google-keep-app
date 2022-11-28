import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:bootleg_google_keep_app/constants/database.dart';
import 'package:bootleg_google_keep_app/models/users_model.dart';
import 'package:bootleg_google_keep_app/models/notes_model.dart';
import 'package:bootleg_google_keep_app/services/notes/crud_exceptions.dart';

final usersModel = UsersModel();
final notesModel = NotesModel();

class NotesService {
  Database? _db;

  List<NotesDatabase> _notes = [];

  final _notesStreamController =
      StreamController<List<NotesDatabase>>.broadcast();

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<UsersDatabase> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<NotesDatabase> updateNote(
      {required NotesDatabase note,
      required String title,
      required String body}) async {
    final db = _getDatabase();
    final updatesCount = await db.update(notesModel.tableName, {
      'id': note.id,
      '${notesModel.notesColumn['title']}': title,
      '${notesModel.notesColumn['body']}': body,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNoteException();
    }

    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);

    return updatedNote;
  }

  Future<Iterable<NotesDatabase>> getAllNotes() async {
    final db = _getDatabase();
    final notes = await db.query(notesModel.tableName);

    final result = notes.map((noteRow) => NotesDatabase.fromRow(noteRow));

    return result;
  }

  Future<NotesDatabase> getNote({required int id}) async {
    final db = _getDatabase();
    final notes = await db.query(notesModel.tableName,
        limit: 1, where: 'id = ?', whereArgs: [id]);

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }

    final note = NotesDatabase.fromRow(notes.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabase();
    final numberOfDeletions = await db.delete(notesModel.tableName);

    _notes = [];
    _notesStreamController.add(_notes);

    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabase();
    final deletedCount =
        await db.delete(notesModel.tableName, where: 'id = ?', whereArgs: [id]);

    if (deletedCount != 1) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<NotesDatabase> createNote(
      {required UsersDatabase owner,
      required String title,
      required String body}) async {
    final db = _getDatabase();

    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    final noteId = await db.insert(notesModel.tableName, {
      '${notesModel.notesColumn['userId']}': owner.id,
      '${notesModel.notesColumn['title']}': title,
      '${notesModel.notesColumn['body']}': body,
      '${notesModel.notesColumn['isSyncedWithCloud']}': 1,
    });

    final note = NotesDatabase(
        id: noteId,
        userId: owner.id,
        title: title,
        body: body,
        isSyncedWithCloud: true);

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<UsersDatabase> getUser({required String email}) async {
    final db = _getDatabase();
    final results = await db.query(usersModel.tableName,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return UsersDatabase.fromRow(results.first);
    }
  }

  Future<UsersDatabase> createUser({required String email}) async {
    final db = _getDatabase();
    final results = await db.query(usersModel.tableName,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(usersModel.tableName,
        {'${usersModel.usersColumn['email']}': email.toLowerCase()});

    return UsersDatabase(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabase();
    final deletedCount = await db.delete(usersModel.tableName,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabase() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "users" (
          "id" INTEGER NOT NULL,
          "email" TEXT NOT_ULL UNIQUE,
          PRIMARY KEY ("id" AUTOINCREMENT)
        );
      ''';
      await db.execute(createUserTable);

      const createNotesTable = '''
        CREATE TABLE IF NOT EXISTS "notes" (
          "id" INTEGER NOT NULL,
          "user_id" INTEGER NOT NULL,
          "title" TEXT,
          "body" TEXT,
          "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY ("id" AUTOINCREMENT),
          FOREIGN KEY ("user_id") REFERENCES "users"("id")
        );
        ''';
      await db.execute(createNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class UsersDatabase {
  final int id;
  final String email;

  const UsersDatabase({required this.id, required this.email});

  UsersDatabase.fromRow(Map<String, Object?> map)
      : id = map[usersModel.usersColumn['id']] as int,
        email = map[usersModel.usersColumn['email']] as String;

  @override
  String toString() => 'Person, id: $id, email: $email';

  @override
  bool operator ==(covariant UsersDatabase other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class NotesDatabase {
  final int id;
  final int userId;
  final String title;
  final String body;
  final bool isSyncedWithCloud;

  const NotesDatabase(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body,
      required this.isSyncedWithCloud});

  NotesDatabase.fromRow(Map<String, Object?> map)
      : id = map[notesModel.notesColumn['id']] as int,
        userId = map[notesModel.notesColumn['userId']] as int,
        title = map[notesModel.notesColumn['title']] as String,
        body = map[notesModel.notesColumn['body']] as String,
        isSyncedWithCloud =
            (map[notesModel.notesColumn['isSyncedWithCloud']] as int) == 1
                ? true
                : false;

  @override
  String toString() =>
      'Your Note,\nid: $id\ntitle: $title\nbody: $body\nis synced: $isSyncedWithCloud';

  @override
  bool operator ==(covariant NotesDatabase other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
