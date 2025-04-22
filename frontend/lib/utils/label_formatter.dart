class LabelFormatter {
  static String format(String? label) {
    if (label == null || label.trim().isEmpty) return 'Unknown';
    return label
        .split(RegExp(r'[_\s]+'))
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
