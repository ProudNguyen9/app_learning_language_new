import 'package:flutter/material.dart';

class ScreenSize {
  static Size getSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getWidth80Percent(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.8;
  }
}
