import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'category.dart';
import '../tag/tag.dart';

import '../document/document.dart';
import '../document/document_details_view.dart';

/// Displays a list of Documents.
class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key, required this.categories});

  static const routeName = '/';

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              print(categories.length);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
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
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final item = categories[index];

          return ListTile(
              title: Text(item.title),
              leading: item.icon,
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                  context,
                  DocumentDetailsView.routeName,
                );
              });
        },
      ),
    );
  }
}
