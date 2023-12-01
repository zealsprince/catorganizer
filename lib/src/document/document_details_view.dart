import 'package:flutter/material.dart';

/// Displays detailed information about a Document.
class DocumentDetailsView extends StatelessWidget {
  const DocumentDetailsView({super.key});

  static const routeName = '/document';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}
