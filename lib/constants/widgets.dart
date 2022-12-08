import 'package:flutter/material.dart';

BoxDecoration containerDecoration({Color? color}) {
  return BoxDecoration(
      border: Border.all(width: 1, color: Colors.black54),
      borderRadius: BorderRadius.circular(12),
      color: color);
}
