import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/classes/document.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/common_widgets/tag_row.dart';
import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/views/document/document_detail_view.dart';

class DocumentInCategoryListViewArguments {
  final String id;
  final Manifest manifest;

  DocumentInCategoryListViewArguments({
    required this.id,
    required this.manifest,
  });
}

class DocumentInCategoryListView extends StatefulWidget {
  final DocumentInCategoryListViewArguments arguments;

  const DocumentInCategoryListView({
    super.key,
    required this.arguments,
  });

  static const routeName = '/categorized-documents';

  @override
  _DocumentInCategoryListViewState createState() =>
      _DocumentInCategoryListViewState();
}

/// Displays a list of documents.
class _DocumentInCategoryListViewState
    extends State<DocumentInCategoryListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.arguments.manifest
              .getCategories()[widget.arguments.id]!
              .title),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => widget.arguments.manifest
                  .addCategorizedDocumentsSelection(widget.arguments.id),
            ),
          ]),
      body: ListenableBuilder(
        listenable: widget.arguments.manifest,
        builder: (context, Widget? child) {
          List<Document> documents = widget.arguments.manifest
              .getCategories()[widget.arguments.id]!
              .documents
              .entries
              .map((documents) => documents.value)
              .toList();

          return ListView.builder(
            restorationId: 'DocumentInCategoryListView',
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final document = documents[index];

              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 68, maxHeight: 68),
                child: Center(
                  child: ListTile(
                      title: Text(document.title),
                      subtitle: document.tags.isEmpty
                          ? null
                          : Tags(
                              count: 5,
                              size: 12,
                              values: document.tags
                                  .map((tag) => tag.value)
                                  .toList(),
                            ),
                      leading: MarkedIcon(
                        color: hexARGBToColor(document.category.color),
                        icon: const Icon(Icons.article_rounded),
                      ),
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
                          arguments: DocumentDetailViewArguments(
                            id: document.uuid,
                            manifest: widget.arguments.manifest,
                          ),
                        );
                      }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
