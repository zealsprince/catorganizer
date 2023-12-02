import 'package:flutter/material.dart';

import 'package:open_app_file/open_app_file.dart';

import 'package:catorganizer/src/classes/document.dart';

import 'package:catorganizer/src/manifest/manifest.dart';

import 'package:catorganizer/src/views/document/document_detail_view.dart';

/// Displays a list of documents.
class DocumentListView extends StatelessWidget {
  final Manifest manifest;

  const DocumentListView({
    super.key,
    required this.manifest,
  });

  static const routeName = '/documents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents'), actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => manifest.addUncategorizedDocumentsSelection(),
        ),
      ]),
      body: ListView.builder(
        restorationId: 'DocumentListView',
        itemCount: manifest.documents.length,
        itemBuilder: (BuildContext context, int index) {
          final document = manifest.documents[index];

          return ListTile(
              title: Text(document.title),
              leading: const Icon(Icons.article_rounded),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_outward_rounded),
                onPressed: () {
                  OpenAppFile.open(document.path);
                },
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.pushNamed(
                  context,
                  DocumentDetailView.routeName,
                  arguments: document,
                );
              });
        },
      ),
    );
  }
}
