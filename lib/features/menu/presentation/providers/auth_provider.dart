import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';

class AuthState {
  final String? token;
  final UserModel? user;

  const AuthState({
    this.token,
    this.user,
  });

  bool get isLoggedIn => token != null && user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setAuth(String token, UserModel user) {
    state = AuthState(
      token: token,
      user: user,
    );
  }

  void updateUser(UserModel user) {
    state = AuthState(
      token: state.token,
      user: user,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

  final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    return AuthNotifier();
  });
