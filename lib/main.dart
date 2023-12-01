import 'package:flutter/material.dart';

import 'src/app.dart';

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'src/category/category.dart';
import 'src/document/document.dart';
import 'src/tag/tag.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  List<Document> documents = <Document>[
    const Document("0", "Testing document", "/test.pdf", <Tag>[])
  ];

  List<Category> categories = <Category>[
    Category(
        "test",
        "Testing Category",
        "This is an example test category",
        const Color(0xFFFFBB00),
        const Icon(Icons.note, color: Color(0xFFFFFFFF)),
        documents)
  ];

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(Catorganizer(
      settingsController: settingsController, categories: categories));
}
