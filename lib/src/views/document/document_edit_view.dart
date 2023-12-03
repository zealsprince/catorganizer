import 'package:flutter/material.dart';

import 'package:catorganizer/src/models/manifest.dart';

class DocumentEditViewArguments {
  final String id;
  final Manifest manifest;

  DocumentEditViewArguments({
    required this.id,
    required this.manifest,
  });
}

/// Displays detailed information about a Document.
class DocumentEditView extends StatelessWidget {
  final DocumentEditViewArguments arguments;

  const DocumentEditView({super.key, required this.arguments});

  static const routeName = '/document-edit';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Title"),
      ),
      body: const Text("Document"),
    );
  }
}
