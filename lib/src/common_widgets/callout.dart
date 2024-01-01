import 'package:flutter/material.dart';

import 'package:catorganizer/src/constants.dart' as constants;

enum CalloutType { error, warning, info, custom }

class Callout extends StatelessWidget {
  final CalloutType type;
  final String message;
  final String detail;

  // Additional variables that are used when specificying the custom type.
  final String customHeader;
  final Color customColor;
  final IconData customIcon;

  const Callout({
    super.key,
    required this.type,
    required this.message,
    this.detail = "",
    this.customColor = const Color(0xFFFFBB33),
    this.customHeader = "Sunny",
    this.customIcon = Icons.sunny,
  });

  @override
  Widget build(BuildContext context) {
    // These are set based on the type of callout specified.
    Color color;
    String header;
    IconData icon;

    switch (type) {
      case CalloutType.error:
        color = const Color(0xFFFF2200);
        header = "Error";
        icon = Icons.error_rounded;

      case CalloutType.warning:
        color = const Color(0xFFFF9900);
        header = "Warning";
        icon = Icons.warning_rounded;

      case CalloutType.info:
        color = constants.defaultColor;
        header = "Notice";
        icon = Icons.info_outline_rounded;

      case CalloutType.custom:
        color = customColor;
        header = customHeader;
        icon = customIcon;
    }

    List<Widget> contentChildren = [
      Container(
        margin: const EdgeInsets.only(top: 16, bottom: 16),
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(128),
          color: color.withAlpha(0x99),
        ),
        child: Icon(
          icon,
          size: 86,
          color: const Color(0xFFFFFFFF),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Text(
          header,
          style: const TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    ];

    // Insert a button at the end if there is additional detail.
    if (detail != "") {
      contentChildren.add(
        Padding(
          padding:
              const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
          child: ElevatedButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(
                color,
              ),
              overlayColor: MaterialStateProperty.all<Color>(
                color.withAlpha(0x44),
              ),
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  title: const Text('Detail'),
                  content: Text(detail),
                );
              },
            ),
            child: const Text("View Details"),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 540,
              maxHeight: 640,
              maxWidth: 540,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.withAlpha(0x22),
                borderRadius: const BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min, children: contentChildren),
            ),
          ),
        )
      ],
    );
  }
}
