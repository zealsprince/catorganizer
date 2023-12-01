import 'package:flutter/material.dart';

class TaggedIcon extends StatelessWidget {
  final Color color;

  Marker({super.key, this.color = const Color(0xFFFF0000)});

  @override
  Widget build(BuildContext context) {
    return Row()(Icons.circle);
  }
}
