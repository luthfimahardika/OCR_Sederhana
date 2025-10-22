import 'dart:io';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final String recognizedText;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.recognizedText,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}
class _ResultScreenState extends State<ResultScreen> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
  }

 Future<void> _initTts() async {
    try {
      await flutterTts.setLanguage("id-ID");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inisialisasi TTS: $e')),
        );
      }
    }
  }

  Future<void> _speak() async {
    if (widget.recognizedText.isNotEmpty) {
      try {
        await flutterTts.speak(widget.recognizedText);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error membaca teks: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada teks untuk dibaca')),
        );
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop TTS engine
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Scan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan gambar yang di-scan
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.imagePath),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            
            // Judul hasil OCR
            const Text(
              'Hasil OCR:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Teks hasil OCR
            // Teks hasil OCR tanpa replaceAll, agar \n ditampilkan utuh
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.recognizedText.isEmpty
                    ? 'Tidak ada teks yang terdeteksi'
                    : widget.recognizedText, // tampilkan teks apa adanya
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol kembali (opsional tetap bisa dipakai)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Scan Lagi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),

      // Tambahkan FloatingActionButton dengan ikon home
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Baca Teks',
            onPressed: _speak,
            child: const Icon(Icons.volume_up),
          ),
          const SizedBox(height: 16),
      FloatingActionButton(
        tooltip: 'Kembali ke Home',
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false, // hapus semua halaman di atas stack
          );
        },
        child: const Icon(Icons.home),
      ),
      ],
      ),
    );
  }
}