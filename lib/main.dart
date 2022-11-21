import 'package:flutter/material.dart';
import 'package:bootleg_google_keep_app/pages/register_page.dart';
import 'package:bootleg_google_keep_app/pages/login_page.dart';

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
        primarySwatch: Colors.deepOrange,
      ),
      home: const RegisterPage(),
    );
  }
}
