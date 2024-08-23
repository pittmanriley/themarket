
import 'package:flutter/services.dart';

class MaxLinesTextInputFormatter extends TextInputFormatter {
  final int maxLines;

  MaxLinesTextInputFormatter(this.maxLines);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newLineCount = '\n'.allMatches(newValue.text).length + 1;

    if (newLineCount > maxLines) {
      return oldValue;
    }

    return newValue;
  }


}