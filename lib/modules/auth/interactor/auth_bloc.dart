import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<UserProfile?> _authStateSubscription;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);

    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage: 'Login failed: Profile not found.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        username: event.username,
      );
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage:
                'Account created! Please verify your email before logging in.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
