import 'package:flutter/material.dart';

import 'package:open_app_file/open_app_file.dart';

import 'package:catorganizer/src/classes/document.dart';
import 'package:catorganizer/src/views/document/document_detail_view.dart';

/// Displays a list of documents.
class DocumentListView extends StatelessWidget {
  final List<Document> documents;
  const DocumentListView({super.key, this.documents = const <Document>[]});

  static const routeName = '/documents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),

      // To work with lists that may contain a large number of documents, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'DocumentListView',
        itemCount: documents.length,
        itemBuilder: (BuildContext context, int index) {
          final document = documents[index];

          return ListTile(
              title: Text(document.title),
              leading: const Icon(Icons.article_rounded),
              trailing: IconButton(
                  icon: const Icon(Icons.arrow_outward_rounded),
                  onPressed: () {
                    OpenAppFile.open(document.path);
                  }),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.pushNamed(context, DocumentDetailView.routeName,
                    arguments: document);
              });
        },
      ),
    );
  }
}
