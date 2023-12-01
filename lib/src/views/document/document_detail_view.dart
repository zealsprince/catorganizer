import 'package:flutter/material.dart';

import 'package:catorganizer/src/classes/document.dart';

/// Displays detailed information about a Document.
class DocumentDetailView extends StatelessWidget {
  final Document document;
  const DocumentDetailView({super.key, required this.document});

  static const routeName = '/document';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
      ),
      body: const Center(
        child: Text('More information and metadata here'),
      ),
    );
  }
}
