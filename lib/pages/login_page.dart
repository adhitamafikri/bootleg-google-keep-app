import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(children: [
        TextField(
          decoration: const InputDecoration(hintText: 'Email'),
          controller: _email,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Password',
          ),
          controller: _password,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
        ),
        TextButton(
            onPressed: () async {
              try {
                final email = _email.text;
                final password = _password.text;
                final userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password);
                devtools.log(userCredential.toString());
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/notes', (route) => false);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  devtools.log('User not found');
                } else if (e.code == 'wrong-password') {
                  devtools.log('Wrong Password');
                } else {
                  devtools.log('Unknown Error');
                  devtools.log(e.code);
                }
              }
            },
            child: const Text('Login')),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/register', (route) => false);
            },
            child: const Text('Not registered yet? Register here!'))
      ]),
    );
  }
}
