  import 'dart:convert';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:http/http.dart' as http;

void main() async {
  
  final url = Uri.parse(
    '${AppKeys.supabaseUrl}/rest/v1/auth.user',
  );

  final response = await http.get(url, headers: {
    'apikey': AppKeys.supabaseAnonKey,
    'Authorization': 'Bearer ${AppKeys.supabaseAnonKey}',
  });

  final data = jsonDecode(response.body);

  if (data is List) {
    print('📄 Data from ${AppKeys.organizationsTable} table:');
    for (var row in data) {
      print(row);
    }
  } else {
    print('❌ Unexpected response: $data');
  }
}
