import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:open_app_file/open_app_file.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/models/document.dart';

import 'package:catorganizer/src/common_widgets/tag_row.dart';
import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/views/document/document_detail_view.dart';
import 'package:catorganizer/src/views/document/document_new_view.dart';

class DocumentListView extends StatefulWidget {
  final ManifestModel manifest;

  const DocumentListView({
    super.key,
    required this.manifest,
  });

  static const routeName = '/documents';

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

/// Displays a list of documents.
class _DocumentListViewState extends State<DocumentListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // It feels like this should be standardized into a generic method call.
              openFile().then(
                (file) {
                  if (file != null) {
                    Navigator.pushNamed(
                      context,
                      DocumentNewView.routeName,
                      arguments: DocumentNewViewArguments(
                          manifest: widget.manifest, file: file),
                    );
                  }
                },
              );
            },
          ),
        ],
        // Search bar
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {}, // Search bar clearing method.
              ),
              contentPadding: const EdgeInsets.only(
                bottom: 10,
              ),
              hintText: 'Search',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.manifest,
        builder: (context, Widget? child) {
          // We'll want to organize our documents here for easier handling.
          List<DocumentModel> documents = widget.manifest
              .getDocuments()
              .entries
              .map((document) => document.value)
              .toList();

          return ListView.builder(
            restorationId: 'DocumentListView',
            itemCount: widget.manifest.getDocuments().length,
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
                            manifest: widget.manifest,
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
