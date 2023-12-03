import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/classes/document.dart';

import 'package:catorganizer/src/common_widgets/tag_row.dart';
import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/views/document/document_detail_view.dart';

class DocumentListView extends StatefulWidget {
  final Manifest manifest;

  const DocumentListView({
    super.key,
    required this.manifest,
  });

  static const routeName = '/documents';

  @override
  _DocumentListViewState createState() => _DocumentListViewState();
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
            onPressed: () =>
                widget.manifest.addUncategorizedDocumentsSelection(),
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
          List<Document> documents = widget.manifest
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
