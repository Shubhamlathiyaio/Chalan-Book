import 'dart:io';

import 'package:chalan_book_app/services/mega_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/models/chalan.dart';

class ChalanDetailPage extends StatelessWidget {
  final Chalan chalan;

  const ChalanDetailPage({super.key, required this.chalan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Image Section
              Expanded(
                child: GestureDetector(
                  onTap: () => _showFullScreenImage(context),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    child: chalan.imageUrl != null
                        ? MegaImageWidget(
                            imageUrl: chalan.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),

              // Details Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chalan Number',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chalan.chalanNumber,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatDate(chalan.dateTime),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chalan.description ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Action Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareChalan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    if (chalan.imageUrl == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Container(
              color: Colors.black,
              child: MegaImageWidget(
                imageUrl: chalan.imageUrl!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

Future<void> _shareChalan() async {
  if (chalan.imageUrl == null) return;

  try {
    print('🔄 Getting image from MEGA...');
    
    // Use your existing MEGA service to get the image bytes
    final bytes = await MegaImageService.getCompressedImage(chalan.imageUrl!);
    
    if (bytes == null) {
      throw Exception('Failed to load image from MEGA');
    }

    print('✅ Got image bytes: ${bytes.length}');

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/chalan_image.jpg').create();
    await file.writeAsBytes(bytes);

    print('✅ Image saved to: ${file.path}');

    await Share.shareXFiles([XFile(file.path)], text: chalan.chalanNumber);
    
    print('✅ Sharing initiated');
    
  } catch (e) {
    print('❌ Error sharing chalan: $e');
    // Optionally show snackbar here with context
  }
}

  // Format date to dd/mm/yyyy
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
