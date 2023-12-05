import 'package:flutter/material.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/common_widgets/tag_row.dart';
import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/models/document.dart';

import 'package:catorganizer/src/views/document/document_edit_view.dart';

class DocumentDetailViewArguments {
  final String id;
  final ManifestModel manifest;

  DocumentDetailViewArguments({
    required this.id,
    required this.manifest,
  });
}

class DocumentDetailView extends StatefulWidget {
  final DocumentDetailViewArguments arguments;

  const DocumentDetailView({super.key, required this.arguments});

  static const routeName = '/document';

  @override
  _DocumentDetailViewState createState() => _DocumentDetailViewState();
}

/// Displays detailed information about a Document.
class _DocumentDetailViewState extends State<DocumentDetailView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.arguments.manifest,
      builder: (context, Widget? child) {
        // Assign the document from the manifest by it's ID if it exists. Otherwise use an empty document.
        DocumentModel document =
            (widget.arguments.manifest.getDocument(widget.arguments.id) != null)
                ? widget.arguments.manifest.getDocument(widget.arguments.id)!
                : DocumentModel.empty();

        return Scaffold(
          appBar: AppBar(title: Text(document.title), actions: [
            IconButton(
                icon: const Icon(Icons.edit_document),
                onPressed: () => Navigator.pushNamed(
                      context,
                      DocumentEditView.routeName,
                      arguments: DocumentEditViewArguments(
                        id: document.uuid,
                        manifest: widget.arguments.manifest,
                      ),
                    )),
          ]),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------- Path ----------------------------
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
                child: Row(
                  children: [
                    Text(
                      "Path:",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
                child: Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          document.path,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // -------------------------- Category --------------------------
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
                child: Row(
                  children: [
                    Text(
                      "Category:",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Row(
                  children: [
                    MarkedIcon(
                      color: document.category.color,
                      icon: document.category.icon,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          document.category.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // --------------------------- Tags ---------------------------
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
                child: Row(
                  children: [
                    Text(
                      document.getTags().isEmpty ? "" : "Tags:",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: TagRow(
                  count: 100,
                  size: 14,
                  values: document.getTags().map((tag) => tag.value).toList(),
                ),
              ),
              // const Divider(),
              // --------------------------- UUID ---------------------------
              // const Padding(
              //   padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
              //   child: Row(
              //     children: [
              //       Text(
              //         "UUID:",
              //         style: TextStyle(
              //           fontSize: 16,
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
              //   child: Row(
              //     children: [
              //       Flexible(
              //         child: Padding(
              //           padding: const EdgeInsets.only(left: 8),
              //           child: Text(
              //             document.uuid,
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
