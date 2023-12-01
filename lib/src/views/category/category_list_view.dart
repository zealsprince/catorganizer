import 'package:flutter/material.dart';

import 'package:catorganizer/src/views/settings/settings_view.dart';
import 'package:catorganizer/src/classes/category.dart';
import 'package:catorganizer/src/views/document/document_list_view.dart';

/// Displays a list of categories.
class CategoryListView extends StatelessWidget {
  final List<Category> categories;
  const CategoryListView({super.key, required this.categories});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => const AlertDialog(
                      title:
                          Text("This will open an OS file selection dialog")))),
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
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = categories[index];

          return ListTile(
              title: Text(category.title),
              leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                category.icon,
                Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(Icons.circle, size: 12, color: category.color)),
              ]),
              splashColor: category.color,
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.pushNamed(context, DocumentListView.routeName,
                    arguments: category.documents);
              });
        },
      ),
    );
  }
}
