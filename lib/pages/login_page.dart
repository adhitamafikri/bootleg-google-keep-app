import 'package:bootleg_google_keep_app/constants/routes.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_exceptions.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_bloc.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_event.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:bootleg_google_keep_app/utils/dialogs/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthStateLoggedOut) {
              if (state.exception is UserNotFoundAuthException) {
                await showErrorDialog(context, 'User not found');
              } else if (state.exception is WrongPasswordAuthException) {
                await showErrorDialog(context, 'Wrong Credentials');
              } else if (state.exception is GenericAuthException) {
                await showErrorDialog(context, 'Authentication Error');
              }
            }
          },
          child: TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogin(email, password));
              },
              child: const Text('Login')),
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not registered yet? Register here!'))
      ]),
    );
  }
}
