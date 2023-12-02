import 'package:flutter/material.dart';

import 'package:open_app_file/open_app_file.dart';

import 'package:catorganizer/src/classes/document.dart';

import 'package:catorganizer/src/manifest/manifest.dart';

import 'package:catorganizer/src/views/document/document_detail_view.dart';

class DocumentInCategoryListViewArguments {
  final String id;
  final Manifest manifest;

  DocumentInCategoryListViewArguments({
    required this.id,
    required this.manifest,
  });
}

/// Displays a list of documents.
class DocumentInCategoryListView extends StatelessWidget {
  final DocumentInCategoryListViewArguments arguments;

  DocumentInCategoryListView({
    super.key,
    required this.arguments,
  }) {
    documents = arguments.manifest.categories[arguments.id]!.documents.entries
        .map((documents) => documents.value)
        .toList();
  }

  List<Document> documents = [];

  static const routeName = '/categorized-documents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents'), actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () =>
              arguments.manifest.addCategorizedDocumentsSelection(arguments.id),
        ),
      ]),
      body: ListView.builder(
        restorationId: 'DocumentListView',
        itemCount: documents.length,
        itemBuilder: (BuildContext context, int index) {
          final document = documents[index];

          return ListTile(
              title: Text(document!.title),
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