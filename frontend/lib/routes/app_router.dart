import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/controller/auth_controller.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/home_screen.dart';
import '../features/auth/screens/profile_screen.dart';

/// GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Redirect based on auth status
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isOnSplash = state.matchedLocation == '/splash';

      // Use splash only for the initial auth check.
      // Don't force splash during login/profile requests because that can
      // create repeated auth/profile fetches and route churn.
      if (isOnSplash) {
        if (authState.isLoading) {
          return null;
        }

        return isAuthenticated ? '/home' : '/login';
      }

      if (authState.isLoading) {
        return null;
      }

      // If not authenticated, redirect to login
      if (!isAuthenticated && !isOnAuthPage && !isOnSplash) {
        return '/login';
      }

      // If authenticated and on auth page, redirect to home
      if (isAuthenticated && isOnAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) {
          // Redirect to splash on app start
          return '/splash';
        },
      ),
    ],
  );
});
