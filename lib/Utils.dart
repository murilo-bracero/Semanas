import 'dart:core';

import 'package:flutter/widgets.dart';

const LIST_START_ID = "list-start";
const LIST_END_ID = "list-end";

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

String normalizeKey(Key key) {
  return key
      .toString()
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll("'", '');
}
