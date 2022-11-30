import 'package:bootleg_google_keep_app/pages/notes/new_note_page.dart';
import 'package:bootleg_google_keep_app/pages/notes/update_note_page.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_service.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_bloc.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_event.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_state.dart';
import 'package:bootleg_google_keep_app/services/auth/firebase_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:bootleg_google_keep_app/pages/register_page.dart';
import 'package:bootleg_google_keep_app/pages/login_page.dart';
import 'package:bootleg_google_keep_app/pages/verify_email_page.dart';
import 'package:bootleg_google_keep_app/pages/notes/notes_page.dart';
import 'package:bootleg_google_keep_app/constants/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(FirebaseAuthProvider()),
              child: const HomePage(),
            ),
        loginRoute: (context) => const LoginPage(),
        registerRoute: (context) => const RegisterPage(),
        verifyEmailRoute: (context) => const VerifyEmailPage(),
        notesRoute: (context) => const NotesPage(),
        newNoteRoute: (context) => const NewNotePage(),
        updateNoteRoute: (context) => const UpdateNotePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        // Navigator.of(context)
        //     .pushNamedAndRemoveUntil(notesRoute, (route) => false);
        return const NotesPage();
      } else if (state is AuthStateNeedsVerification) {
        // Navigator.of(context)
        //     .pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
        return const VerifyEmailPage();
      } else if (state is AuthStateLoggedOut) {
        // Navigator.of(context)
        //     .pushNamedAndRemoveUntil(loginRoute, (route) => false);
        return const LoginPage();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });

    // return FutureBuilder(
    //     future: AuthService.firebase().initialize(),
    //     builder: (context, snapshot) {
    //       switch (snapshot.connectionState) {
    //         case ConnectionState.done:
    //           final user = AuthService.firebase().currentUser;
    //           if (user != null) {
    //             final emailVerified = user.isEmailVerified;
    //             if (emailVerified) {
    //               return const NotesPage();
    //             } else {
    //               return const VerifyEmailPage();
    //             }
    //           }
    //           return const LoginPage();
    //         default:
    //           return const CircularProgressIndicator();
    //       }
    //     });
  }
}
