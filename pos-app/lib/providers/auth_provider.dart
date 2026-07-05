import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';

class AuthState {
  final bool isLoggedIn;
  final String? username;
  const AuthState({this.isLoggedIn = false, this.username});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Mock login. Ganti dengan Supabase Auth saat siap.
  bool login(String username, String password) {
    if (username.trim() == AppConstants.mockUsername &&
        password == AppConstants.mockPassword) {
      state = AuthState(isLoggedIn: true, username: username.trim());
      return true;
    }
    // Untuk kemudahan demo skripsi: terima apapun yang tidak kosong.
    if (username.trim().isNotEmpty && password.isNotEmpty) {
      state = AuthState(isLoggedIn: true, username: username.trim());
      return true;
    }
    return false;
  }

  void logout() => state = const AuthState();
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
