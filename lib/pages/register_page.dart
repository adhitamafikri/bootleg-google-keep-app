import 'package:bootleg_google_keep_app/constants/routes.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_exceptions.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_service.dart';
import 'package:bootleg_google_keep_app/utils/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
      appBar: AppBar(title: const Text('Register')),
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

                await AuthService.firebase()
                    .createUser(email: email, password: password);
              } on EmailAlreadyInUseException {
                await showErrorDialog(context, 'Email is already in use');
              } on WeakPasswordAuthException {
                await showErrorDialog(context, 'Weak Password');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Invalid Email');
              } on GenericAuthException {
                await showErrorDialog(context, 'Registration Failed');
              }
            },
            child: const Text('Register')),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Have an account? Login here!'))
      ]),
    );
  }
}
