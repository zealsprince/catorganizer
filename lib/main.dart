import 'package:flutter/material.dart';

import 'src/app.dart';

import 'src/views/settings/settings_controller.dart';
import 'src/views/settings/settings_service.dart';

import 'src/classes/category.dart';
import 'src/classes/document.dart';
import 'src/classes/tag.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // TODO: Create state loader for documents and categories.

  List<Document> documents = <Document>[
    const Document("0", "Test A Document", "/testA.pdf", <Tag>[Tag("shared")]),
    const Document("1", "Test B Document", "/testB.pdf",
        <Tag>[Tag("shared"), Tag("unique")])
  ];

  List<Category> categories = <Category>[
    Category("test", "Tests", "This is an example testing category",
        const Color(0xFFFFBB00), const Icon(Icons.folder), documents)
  ];

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(Catorganizer(
      settingsController: settingsController, categories: categories));
}
