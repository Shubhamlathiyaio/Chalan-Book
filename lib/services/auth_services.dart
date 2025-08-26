import 'package:chalan_book_app/main.dart';

class AuthService {
  // Signup: Only handle user signup, no profile insertion here
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      print("Signup response: ${response.user}");

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Signup successful! Check your email for verification link 📧',
          'userId': response.user!.id,
        };
      }

      return {'success': false, 'error': 'Signup failed'};
    } catch (e) {
      print('Signup error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Login: Handle login and return user or error
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Login successful! 🚀',
          'user': response.user,
          'session': response.session,
        };
      }
      return {'success': false, 'error': 'Login failed'};
    } catch (e) {
      if (e.toString().contains('email not confirmed')) {
        return await sendMagicLink(email);
      }
      print('Login error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Send magic link for email verification or unconfirmed sign-ins
  Future<Map<String, dynamic>> sendMagicLink(String email) async {
    try {
      await supabase.auth.signInWithOtp(email: email);
      return {
        'success': true,
        'message': 'Verification link sent! Check your email 📧',
        'needsVerification': true,
      };
    } catch (e) {
      print('Magic link error: $e');
      return {'success': false, 'error': 'Failed to send verification email'};
    }
  }

    Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
  }

}
