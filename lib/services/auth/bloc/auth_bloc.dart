import 'package:bloc/bloc.dart';
import 'package:bootleg_google_keep_app/services/auth/auth_provider.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_event.dart';
import 'package:bootleg_google_keep_app/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    // Initialize
    on<AuthEventInitialize>((_, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    // Login
    on<AuthEventLogin>((event, emit) async {
      try {
        final user =
            await provider.login(email: event.email, password: event.password);
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    });

    // Logou
    on<AuthEventLogout>((_, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logout();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    });
  }
}
