import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import 'package:catorganizer/src/common_widgets/callout.dart';
import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/models/category.dart';
import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/views/settings/settings_view.dart';
import 'package:catorganizer/src/views/category/category_grid_view.dart';
import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';
import 'package:catorganizer/src/views/document/document_new_view.dart';

class CategoryListView extends StatefulWidget {
  final ManifestModel manifest;

  const CategoryListView({super.key, required this.manifest});

  static const routeName = '/category-list';

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

/// Displays a list of categories.
class _CategoryListViewState extends State<CategoryListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                DocumentListView.routeName,
                arguments: widget.manifest,
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              CategoryGridView.routeName,
            ),
          ),
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
                      manifest: widget.manifest,
                      file: file,
                    ),
                  );
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.pushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of documents, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListenableBuilder(
        listenable: widget.manifest,
        builder: (context, Widget? child) {
          if (widget.manifest.error != "") {
            return Callout(
              type: CalloutType.error,
              message:
                  "It appears there's an issue with loading the application manifest",
              detail: widget.manifest.error,
            );
          }

          List<CategoryModel> categoriesList = widget.manifest
              .getCategories()
              .entries
              .map((category) => category.value)
              .toList();

          return ListView.builder(
            // Providing a restorationId allows the ListView to restore the
            // scroll position when a user leaves and returns to the app after it
            // has been killed while running in the background.
            restorationId: 'CategoryListView',
            itemCount: widget.manifest.getCategories().length,
            itemBuilder: (BuildContext context, int index) {
              final category = categoriesList[index];

              return ListTile(
                  title: Text(category.title),
                  trailing: Text('(${category.getDocumets().length})'),
                  leading: MarkedIcon(
                    color: category.color,
                    icon: category.icon,
                  ),
                  splashColor: category.color.withAlpha(0x11),
                  onTap: () {
                    // Navigate to the details page. If the user leaves and returns to
                    // the app after it has been killed while running in the
                    // background, the navigation stack is restored.
                    Navigator.pushNamed(
                      context,
                      DocumentInCategoryListView.routeName,
                      arguments: DocumentInCategoryListViewArguments(
                          category: category, manifest: widget.manifest),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
