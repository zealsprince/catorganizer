import 'package:flutter/material.dart';

class MarkedIcon extends StatelessWidget {
  final Color color;
  final Icon icon;

  const MarkedIcon({
    super.key,
    this.color = const Color(0xFFFF0000),
    this.icon = const Icon(Icons.square_rounded),
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      icon,
      Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(
          Icons.circle,
          size: 12,
          color: color,
        ),
      ),
    ]);
  }
}
