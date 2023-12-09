import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:file_selector/file_selector.dart';

import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/document.dart';
import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/common_widgets/tag_row.dart';
import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/views/document/document_detail_view.dart';
import 'package:catorganizer/src/views/document/document_new_view.dart';

class DocumentInCategoryListViewArguments {
  final ManifestModel manifest;
  final CategoryModel category;

  DocumentInCategoryListViewArguments({
    required this.manifest,
    required this.category,
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
  State<DocumentInCategoryListView> createState() =>
      _DocumentInCategoryListViewState();
}

/// Displays a list of documents.
class _DocumentInCategoryListViewState
    extends State<DocumentInCategoryListView> {
  void addDocument() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments.category.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // It feels like this should be standardized into a generic method call.
              openFile().then((file) {
                if (file != null) {
                  Navigator.pushNamed(
                    context,
                    DocumentNewView.routeName,
                    arguments: DocumentNewViewArguments(
                        manifest: widget.arguments.manifest,
                        category: widget.arguments.category,
                        file: file),
                  );
                }
              });
            },
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.arguments.manifest,
        builder: (context, Widget? child) {
          List<DocumentModel> documents = widget.arguments.category
              .getDocumets()
              .entries
              .map((document) => document.value)
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
                      title: Text(
                        document.title.length >
                                52 // Limit the length of titles.
                            ? '${document.title.substring(0, 49)}...'
                            : document.title,
                      ),
                      subtitle: document.getTags().isEmpty
                          ? null
                          : TagRow(
                              count: 5,
                              size: 12,
                              values: document
                                  .getTags()
                                  .map((tag) => tag.value)
                                  .toList(),
                            ),
                      leading: MarkedIcon(
                        color: document.category.color,
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
