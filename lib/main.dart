import 'package:bootleg_google_keep_app/services/auth/auth_provider.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:bootleg_google_keep_app/pages/register_page.dart';
import 'package:bootleg_google_keep_app/pages/login_page.dart';
import 'package:bootleg_google_keep_app/pages/verify_email_page.dart';
import 'package:bootleg_google_keep_app/pages/notes_page.dart';
import 'package:bootleg_google_keep_app/constants/routes.dart';

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
        '/': (context) => const HomePage(),
        loginRoute: (context) => const LoginPage(),
        registerRoute: (context) => const RegisterPage(),
        verifyEmailRoute: (context) => const VerifyEmailPage(),
        notesRoute: (context) => const NotesPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                final emailVerified = user.isEmailVerified;
                if (emailVerified) {
                  return const NotesPage();
                } else {
                  return const VerifyEmailPage();
                }
              }
              return const LoginPage();
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
