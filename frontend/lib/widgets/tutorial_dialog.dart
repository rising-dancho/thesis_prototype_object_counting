import 'package:flutter/material.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, 
      insetPadding: const EdgeInsets.all(16), 
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FF), 
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color.fromARGB(255, 22, 165, 221)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'How to Use TecTags App',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 22, 165, 221),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStep(
              icon: Icons.camera_alt,
              text: 'Tap "Capture Photo" to take a new picture.',
            ),
            _buildStep(
              icon: Icons.image,
              text: 'Or tap "Choose an Image" to select from gallery.',
            ),
            _buildStep(
              icon: Icons.add_box_outlined,
              text: 'Use the "+" icon to add bounding boxes.',
            ),
            _buildStep(
              icon: Icons.close,
              text: 'Use the "×" icon to remove boxes.',
            ),
            _buildStep(
              icon: Icons.visibility,
              text: 'Toggle "Bounding Boxes" to show/hide labels.',
            ),
            _buildStep(
              icon: Icons.save,
              text: 'Tap "Save" to export the annotated image.',
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required IconData icon, required String text}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // Card background color
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color.fromARGB(255, 22, 165, 221)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
