import 'package:flutter/material.dart';

class Tags extends StatelessWidget {
  final int count;
  final double size;
  final List<String> values;

  const Tags({
    super.key,
    this.count = 3,
    this.size = 16,
    this.values = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      // Return an empty container if there are no values present.
      return const SizedBox.shrink();
    }

    List<Widget> children = []; // Prepare our children list.
    // Iterate over values and build out the tag widgets accordingly.
    for (int i = 0; i < values.length; i++) {
      if (i >= count) {
        // If the next tag is beyond the count; stop, truncate and append text.
        children.add(Text('+${values.length - count}'));
        break;
      }

      children.add(
        Padding(
          padding: EdgeInsets.only(right: size / 4),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(size * 2)),
                color: const Color(0x11000000)),
            child: Padding(
              padding: EdgeInsets.all(size / 2),
              child: Text(
                '#${values[i]}',
                style: TextStyle(fontSize: size * 1),
              ),
            ),
          ),
        ),
      );
    }

    // Send back all built children.
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
