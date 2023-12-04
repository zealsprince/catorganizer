import 'package:flutter/material.dart';

import 'package:catorganizer/src/helpers/helpers.dart';

import 'package:catorganizer/src/classes/category.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/views/settings/settings_view.dart';
import 'package:catorganizer/src/views/category/category_grid_view.dart';
import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';

class CategoryListView extends StatefulWidget {
  final Manifest manifest;

  const CategoryListView({super.key, required this.manifest});

  static const routeName = '/category-list';

  @override
  CategoryListViewState createState() => CategoryListViewState();
}

/// Displays a list of categories.
class CategoryListViewState extends State<CategoryListView> {
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
            onPressed: () =>
                widget.manifest.addUncategorizedDocumentsSelection(),
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
          List<Category> categoriesList = widget.manifest
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
                    color: hexARGBToColor(category.color),
                    icon: Icon(getMaterialIcon(category.icon)),
                  ),
                  splashColor: hexARGBToColor(category.color).withAlpha(0x11),
                  onTap: () {
                    // Navigate to the details page. If the user leaves and returns to
                    // the app after it has been killed while running in the
                    // background, the navigation stack is restored.
                    Navigator.pushNamed(
                      context,
                      DocumentInCategoryListView.routeName,
                      arguments: DocumentInCategoryListViewArguments(
                          id: category.id, manifest: widget.manifest),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
