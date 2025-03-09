import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// A reusable photo viewer widget
class PhotoViewer extends StatelessWidget {
  final File imageFile;

  const PhotoViewer({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // Optional: Rounds corners if needed
      borderRadius: BorderRadius.circular(12),
      child: PhotoView(
        imageProvider: FileImage(imageFile),
        minScale: PhotoViewComputedScale.contained * 1.0,
        maxScale: PhotoViewComputedScale.covered * 2.0,
        backgroundDecoration: BoxDecoration(color: Colors.white),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}