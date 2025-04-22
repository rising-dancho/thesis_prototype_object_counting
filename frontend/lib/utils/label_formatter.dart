class LabelFormatter {
  static String titleCase(String? label) {
    if (label == null || label.trim().isEmpty) return 'Unknown';
    return label
        .split(RegExp(r'[_\s]+'))
        .where((word) => word.trim().isNotEmpty) // ✅ Filter empty
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}