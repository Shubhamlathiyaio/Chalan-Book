import 'dart:io';
import 'package:chalan_book_app/services/supa.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

Future<void> exportChalansToCSV(String orgId) async {
  final response = await Supa()
      .from('chalans')
      .select()
      .eq('organization_id', orgId);

  if (response == null || response.isEmpty) {
    print('No chalans found');
    return;
  }

  // Explicitly define headers matching your table columns exactly
  List<String> headers = [
    'chalan_number',
    'date_time',
    'image_url',
    'description',
    'organization_id',
    'created_by',
    'id',
  ];
  List<List<dynamic>> rows = [headers];

  for (final rawRow in response) {
    List<dynamic> row = [];
    for (final h in headers) {
      var value = rawRow[h];

      // Fix the date_time column: convert DD-MM-YY to YYYY-MM-DD HH:mm:ss
      if (h == 'date_time' && value != null) {
        if (value is String && value.contains('-') && value.length == 8) {
          final parts = value.split('-'); // [DD, MM, YY]
          value =
              '20${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')} 00:00:00';
        } else if (value is DateTime) {
          // Format DateTime to proper string format if needed
          value = '${value.toIso8601String().split('T').first} 00:00:00';
        }
      }

      // Sanitize 'null' strings and null values
      if (value == null || value == 'null') {
        value = '';
      }

      row.add(value);
    }
    rows.add(row);
  }

  String csvData = const ListToCsvConverter().convert(rows);

  final dir = await getExternalStorageDirectory();
  final file = File('${dir?.path}/chalans_export.csv');
  await file.writeAsString(csvData);

  print('✅ Chalans exported at: ${file.path}');
}
