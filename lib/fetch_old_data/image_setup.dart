import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:chalan_book_app/services/mega_image_service.dart';

class ImageSetupPage extends StatefulWidget {
  const ImageSetupPage({super.key});

  @override
  State<ImageSetupPage> createState() => _ImageSetupPageState();
}

class _ImageSetupPageState extends State<ImageSetupPage> {
  final List<String> imageUrls = [
    'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/c0028212-e220-429b-968c-725dc8756cf2_1753522398647.jpg',
    'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/656ccd98-5135-455c-971c-78eaca5c81d9.jpg',
    'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/12ff54ba-a739-48c4-b0bd-955e7f3c3027.jpg',
    'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/fde99aac-7954-4029-81ac-e2fb607e7b90.jpg',
    'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/fbb4ad50-056e-43ea-bdeb-463621bb13b8.jpg',
  ];

  bool _isLoading = false;
  final List<String> _megaUrls = [];

  Future<void> _processImages() async {
    setState(() {
      _isLoading = true;
      _megaUrls.clear();
    });

    for (int i = 0; i < imageUrls.length; i++) {
      final url = imageUrls[i];
      try {
        print("⬇️ Downloading image: $url");
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          print("⏫ Uploading to Mega...");
          final newUrl = await MegaImageService.uploadImageBytes(
            bytes: response.bodyBytes,
            fileName: "image_$i.jpg",
          );

          if (newUrl != null) {
            print("✅ Uploaded: $newUrl");
            _megaUrls.add(newUrl);
          } else {
            print("❌ Upload failed for $url");
          }
        } else {
          print("❌ Failed to download $url");
        }
      } catch (e) {
        print("❌ Error: $e");
      }
    }

    setState(() => _isLoading = false);
  }

  void _copyAllUrls() {
    if (_megaUrls.isNotEmpty) {
      final joined = _megaUrls.join("\n");
      Clipboard.setData(ClipboardData(text: joined));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ All URLs copied to clipboard")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Images to Mega")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _processImages,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload & Get URLs"),
            ),
            const SizedBox(height: 20),
            if (_megaUrls.isNotEmpty) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _megaUrls.join("\n\n"),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _copyAllUrls,
                icon: const Icon(Icons.copy),
                label: const Text("Copy All URLs"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/*

'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/c0028212-e220-429b-968c-725dc8756cf2_1753522398647.jpg',
'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/656ccd98-5135-455c-971c-78eaca5c81d9.jpg',
'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/12ff54ba-a739-48c4-b0bd-955e7f3c3027.jpg',
'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/fde99aac-7954-4029-81ac-e2fb607e7b90.jpg',
'https://adyrowyzxxggcbblndcb.supabase.co/storage/v1/object/public/images/fbb4ad50-056e-43ea-bdeb-463621bb13b8.jpg',


*/