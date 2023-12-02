import 'package:flutter/material.dart';

import 'package:catorganizer/src/classes/category.dart';

import 'package:catorganizer/src/manifest/manifest.dart';

import 'package:catorganizer/src/common_widgets/marked_icon.dart';

import 'package:catorganizer/src/views/settings/settings_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';

/// Displays a list of categories.
class CategoryListView extends StatelessWidget {
  final Manifest manifest;

  late final List<Category> categoriesList;

  CategoryListView({super.key, required this.manifest}) {
    categoriesList =
        manifest.categories.entries.map((category) => category.value).toList();
  }

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => manifest.addUncategorizedDocumentsSelection(),
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
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'CategoryListView',
        itemCount: manifest.categories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = categoriesList[index];

          return ListTile(
              title: Text(category.title),
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
                      id: category.id, manifest: manifest),
                );
              });
        },
      ),
    );
  }
}
