import 'package:flutter/material.dart';

class TutorialDialog extends StatelessWidget {
  final VoidCallback? onStartShowcase;

  const TutorialDialog({super.key, this.onStartShowcase});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F2),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      _StepTile(icon: Icons.camera_alt, text: 'Tap "Capture Photo" to take a new picture.'),
                      _StepTile(icon: Icons.image, text: 'Or tap "Choose an Image" to select from gallery.'),
                      _StepTile(icon: Icons.add_box_outlined, text: 'Use the "+" icon to add bounding boxes.'),
                      _StepTile(icon: Icons.close, text: 'Use the "×" icon to remove boxes.'),
                      _StepTile(icon: Icons.visibility, text: 'Toggle "Bounding Boxes" to show/hide labels.'),
                      _StepTile(icon: Icons.save, text: 'Tap "Save" to export the annotated image.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onStartShowcase != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.delayed(
                          const Duration(milliseconds: 300),
                          onStartShowcase!,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Start Tour'),
                    ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Got it!'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info, size: 28, color: Color.fromARGB(255, 22, 165, 221)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'How to Use TecTags',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 22, 165, 221),
                ),
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StepTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color.fromARGB(255, 22, 165, 221)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
