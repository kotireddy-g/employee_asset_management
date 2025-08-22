import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await ApiService.login(username, password);

    if (response.success && response.data != null) {
      final token = response.data!['data']['token'];
      final user = response.data!['data']['user'];

      // Save token
      await LocalStorageService.setString('auth_token', token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: User.fromJson(user),
        token: token,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Login failed',
      );
    }
  }

  Future<void> logout() async {
    await LocalStorageService.remove('auth_token');
    state = AuthState.initial();
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? token;
  final String? error;

  AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.user,
    this.token,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? token,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
    );
  }
}