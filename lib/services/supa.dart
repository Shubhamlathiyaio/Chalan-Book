import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:chalan_book_app/core/constants/app_keys.dart';

class Supa {
  final bool useNew;
  late final SupabaseClient _client;
  
  // Getters
  SupabaseStorageClient get storage => _client.storage;
  String? get currentUserId => _client.auth.currentUser?.id;
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  String? get authToken => _client.auth.currentSession?.accessToken;

  // For Edge Function/REST calls
  final String? edgeFunctionUrl;
  final String? customAuthToken;

  Supa({
    this.useNew = true,
    this.edgeFunctionUrl,
    this.customAuthToken,
  }) {
    if (useNew) {
      // Use the global initialized client
      _client = Supabase.instance.client;
    } else {
      // Create separate client for old database
      _client = SupabaseClient(
        AppKeys.oldSupabaseUrl,
        AppKeys.oldSupabaseAnonKey,
      );
    }
  }

  // Query helper
  SupabaseQueryBuilder from(String table) => _client.from(table);

  // Edge function helper
  Future<http.Response?> addMemberToOrganization({
    required String organizationId,
    required String userId,
  }) async {
    final token = customAuthToken ?? authToken;
    if (edgeFunctionUrl == null || token == null) return null;
    
    final res = await http.post(
      Uri.parse(edgeFunctionUrl!),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: '{"organizationId":"$organizationId","userId":"$userId"}',
    );
    return res;
  }
}
