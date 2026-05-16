import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../models/user_model.dart';
import '../repository/auth_repository.dart';


/// API Service Provider
final apiServiceProvider = Provider((ref) {
  return ApiService();
});

/// Auth Repository Provider
final authRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRepository(apiService: apiService);
});

/// Authentication State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// Auth Controller using StateNotifier
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  bool _isFetchingProfile = false;

  AuthController(this.authRepository) : super(AuthState());

  /// Check if user is logged in on app start
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        // Try to fetch user profile
        final result = await authRepository.getProfile();
        if (result['success']) {
          final user = User.fromJson(result['data']);
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
            isLoading: false,
            error: null,
          );
        } else {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            error: result['message'],
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check authentication: $e',
      );
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('AuthController.register called for $email');
      final result = await authRepository.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      print('AuthController.register result: $result');

      if (result['success']) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: result['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed: $e',
      );
      return false;
    }
  }

  /// Login user
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await authRepository.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;

        // Set a provisional user immediately so the UI can navigate to home.
        // A full profile refresh will run in the background after login.
        final provisionalUser = User(
          id: data['userId'] as int,
          name: data['name'] as String,
          email: data['email'] as String,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: provisionalUser,
          error: null,
        );

        fetchProfile();
        return true;
      }

      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await authRepository.logout();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Logout failed: $e');
    }
  }

  /// Fetch user profile
  Future<void> fetchProfile() async {
    if (_isFetchingProfile) return;
    _isFetchingProfile = true;
    state = state.copyWith(isLoading: true);
    try {
      final result = await authRepository.getProfile();
      if (result['success']) {
        final user = User.fromJson(result['data']);
        state = state.copyWith(isLoading: false, user: user, error: null);
      } else {
        state = state.copyWith(isLoading: false, error: result['message']);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch profile: $e',
      );
    } finally {
      _isFetchingProfile = false;
    }
  }
}

/// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthController(authRepository);
  },
);
