class PhoneNumberFormatter {
  static String format(String? number) {
    if (number == null ||
        number.trim().length != 11 ||
        !RegExp(r'^09\d{9}$').hasMatch(number)) {
      return 'Invalid number';
    }

    return '${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}';
  }
}
