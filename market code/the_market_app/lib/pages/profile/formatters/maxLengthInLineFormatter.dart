import 'package:flutter/services.dart';

class MaxLengthPerLineInputFormatter extends TextInputFormatter {
  final int maxLength;

  MaxLengthPerLineInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final texts = newValue.text.split('\n');
    final maxLengthExceeded = texts.any((text) => text.length > maxLength);

    if (maxLengthExceeded) {
      return oldValue;
    }

    return newValue;
  }
}
