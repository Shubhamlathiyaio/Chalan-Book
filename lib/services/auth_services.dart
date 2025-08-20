import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // 🔐 SIGN UP - Email only with magic link
  Future<Map<String, dynamic>> signUp({ required String name,required String email,required String password}) async {
    try {
      final response = await supabase.auth.signUp(
        password: password,
        email: email,
        data: {'name': name}, // Custom user metadata
      );

      if (response.user != null) {
        // Insert into profiles table (not users)
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
        });
        
        return {
          'success': true,
          'message': 'Signup successful! Check your email for verification link 📧',
          'userId': response.user!.id
        };
      }
      
      return {'success': false, 'error': 'Signup failed'};
    } catch (e) {
      print('Signup error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // 🔑 LOGIN - Email + password with magic link fallback

  Future<Map<String, dynamic>> login({required String email,required String password}) async {
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
          'session': response.session
        };
      }
      
      return {'success': false, 'error': 'Login failed'};
    } catch (e) {
      // If email not confirmed, send magic link
      if (e.toString().contains('email not confirmed')) {
        return await sendMagicLink(email);
      }
      
      print('Login error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✉️ SEND MAGIC LINK - For unverified emails
  Future<Map<String, dynamic>> sendMagicLink(String email) async {
    try {
      await supabase.auth.signInWithOtp(email: email);
      return {
        'success': true,
        'message': 'Verification link sent! Check your email 📧',
        'needsVerification': true
      };
    } catch (e) {
      print('Magic link error: $e');
      return {'success': false, 'error': 'Failed to send verification email'};
    }
  }

  // 🚪 LOGOUT
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // 👤 GET CURRENT USER
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // 🔍 CHECK IF LOGGED IN
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // 📧 GET USER PROFILE
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // ✏️ UPDATE USER PROFILE
  Future<bool> updateProfile({String? name, String? email}) async {
    try {
      final user = getCurrentUser();
      if (user == null) return false;

      await supabase.from('profiles').update({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      }).eq('id', user.id);

      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}
