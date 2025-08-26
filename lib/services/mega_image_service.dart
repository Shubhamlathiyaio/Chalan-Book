import 'dart:io';
import 'dart:typed_data';
import 'package:chalan_book_app/core/constants/app_keys.dart';
import 'package:chalan_book_app/core/extensions/context_extension.dart';
import 'package:chalan_book_app/services/supa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class MegaImageService {
  static const String _uploadFunctionUrl = AppKeys.uploadToMegaUrl;
  static const String _downloadFunctionUrl = AppKeys.getMegaImageUrl;

  /// Upload compressed image to Mega via Edge Function
  static Future<String?> uploadImage({required File imageFile}) async {
    try {
      print('🔄 Compressing image...');

      // Compress image first
      final compressedFile = await _compressImage(imageFile);
      if (compressedFile == null) return null;

      print('🔄 Uploading to Mega...');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_uploadFunctionUrl),
      );
      request.headers['Authorization'] = 'Bearer ${Supa().authToken}';
      request.headers['apikey'] = AppKeys.newSupabaseAnonKey;

      // Add compressed image
      request.files.add(
        await http.MultipartFile.fromPath('image', compressedFile.path),
      );

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['success']) {
          print('✅ Image uploaded: ${data['url']}');
          return data['url'];
        }
      }

      print('❌ Upload failed: $responseBody');
      return null;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  /// Upload image directly from bytes (Web-compatible)
  static Future<String?> uploadImageBytes({
    required Uint8List bytes,
    String? fileName,
    int quality = 85,
  }) async {
    try {
      print('🔄 Uploading image from bytes...');

      // Temporary file for compression
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        "${tempDir.path}/${fileName ?? "upload_${DateTime.now().millisecondsSinceEpoch}.jpg"}",
      );
      await tempFile.writeAsBytes(bytes);

      // Compress before upload
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        tempFile.path,
        "${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
        quality: quality,
        minWidth: 800,
        minHeight: 600,
      );

      if (compressedFile == null) {
        print('❌ Compression failed');
        return null;
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_uploadFunctionUrl),
      );
      request.headers['Authorization'] = 'Bearer ${Supa().authToken}';
      request.headers['apikey'] = AppKeys.newSupabaseAnonKey;

      // Add compressed file
      request.files.add(
        await http.MultipartFile.fromPath('image', compressedFile.path),
      );

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['success']) {
          print('✅ Image uploaded: ${data['url']}');
          return data['url'];
        }
      }

      print('❌ Upload failed: $responseBody');
      return null;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  /// Get compressed image from Mega URL via Edge Function
  static Future<Uint8List?> getCompressedImage(
    String megaUrl, {
    int quality = 80,
  }) async {
    try {
      print('🔄 Fetching compressed image from: $megaUrl');

      final response = await http.post(
        Uri.parse(_downloadFunctionUrl),
        headers: {
          'Authorization': 'Bearer ${Supa().authToken}',
          'apikey': AppKeys.newSupabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'url': megaUrl, 'quality': quality}),
      );

      if (response.statusCode == 200) {
        print('✅ Image fetched successfully');
        return response.bodyBytes;
      }

      print('❌ Fetch failed: ${response.body}');
      return null;
    } catch (e) {
      print('❌ Fetch error: $e');
      return null;
    }
  }

  /// Compress image before upload
  static Future<File?> _compressImage(File file) async {
    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 85,
        minWidth: 800,
        minHeight: 600,
      );

      return compressedFile != null ? File(compressedFile.path) : null;
    } catch (e) {
      print('Compression error: $e');
      return null;
    }
  }

}
// Create new file: lib/widgets/mega_image_widget.dart

class MegaImageWidget extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MegaImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MegaImageWidget> createState() => _MegaImageWidgetState();
}

class _MegaImageWidgetState extends State<MegaImageWidget> {
  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImage();
  }

  Future<Uint8List?> _loadImage() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return null;
    }
    return await MegaImageService.getCompressedImage(widget.imageUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state - matches your original style
          return Center(
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          // Error state - matches your original style
          return Icon(
            Icons.receipt_long,
            color: context.colors.primary,
            size: 24.w,
          );
        }

        // Success - show MEGA image
        return Image.memory(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }
}
