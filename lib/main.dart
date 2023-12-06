import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:catorganizer/src/app.dart';

import 'package:catorganizer/src/models/manifest.dart';

import 'package:catorganizer/src/views/settings/settings_controller.dart';
import 'package:catorganizer/src/views/settings/settings_service.dart';

void main() async {
  // Ensure bindings are initialized and then bind the custom window manager.
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 800),
    minimumSize: Size(600, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitle('Catorganizer');
    await windowManager.show();
    await windowManager.focus();
  });

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  ManifestModel manifest = ManifestModel();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(Catorganizer(
    settingsController: settingsController,
    manifest: manifest,
  ));
}
