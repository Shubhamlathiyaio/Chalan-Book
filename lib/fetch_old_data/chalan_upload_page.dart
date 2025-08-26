import 'dart:convert';
import 'dart:io';

import 'package:chalan_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ChalanUploadPage extends StatefulWidget {
  const ChalanUploadPage({super.key});

  @override
  State<ChalanUploadPage> createState() => _ChalanUploadPageState();
}

class _ChalanUploadPageState extends State<ChalanUploadPage> {
  bool _isUploading = false;
  int _progress = 0;
  String? _status;

  Future<void> _pickCsvAndUpload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _isUploading = true;
        _progress = 0;
        _status = "Uploading...";
      });
      await _uploadCsv(result.files.single.path!);
      setState(() {
        _isUploading = false;
        _status = "Upload completed!";
      });
    }
  }

  Future<void> _uploadCsv(String path) async {
    // Read CSV file and parse data
    final csvText = await File(path).readAsString();
    final lines = const LineSplitter().convert(csvText);
    for (int i = 1; i < lines.length; i++) { // Assume first line is header
      final values = lines[i].split(',');
      // Map fields (customize these indexes as per your CSV structure)
      final data = {
        'chalan_number': values[0],
        'date_time': values[1],
        'image_url': values[2],
        'description': values[3],
        'organization_id': values[4],
        'created_by': values[5],
        'id': values[6],
      };
      // Insert into Supabase table
      supabase.from('chalan_table').insert(data);
      setState(() {
        _progress = i;
      });
      await Future.delayed(const Duration(milliseconds: 100)); // For UI update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bulk Chalan Upload")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isUploading ? null : _pickCsvAndUpload,
              child: const Text("Choose CSV File"),
            ),
            if (_isUploading)
              LinearProgressIndicator(value: _progress / 953),
            if (_status != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_status!),
              ),
          ],
        ),
      ),
    );
  }
}
