import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> signUp(String name, String? email, String? phone, String password) async {
    try {
      final response = await supabase.auth.signUp(
        password: password,
        email: email,
        phone: phone,
        data: {'name': name}, // Custom user metadata
      );

      if (response.user != null) {
        // Link to custom users table
        await supabase.from('users').insert({
          'user_id': response.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
        });
      }
    } catch (e) {
      print('Signup error: $e');
      // Handle errors (e.g., duplicate email/phone)
    }
  }
}