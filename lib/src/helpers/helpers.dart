import 'package:flutter/material.dart';

Color hexARGBToColor(String hex) {
  return Color(int.parse(hex, radix: 16));
}

Color hexRGBToColor(String hex) {
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}

IconData getMaterialIcon(int codePoint) {
  return IconData(codePoint, fontFamily: 'MaterialIcons');
}
