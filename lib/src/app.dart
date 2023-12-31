import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:catorganizer/src/models/manifest.dart';
import 'package:catorganizer/src/models/category.dart';

import 'package:catorganizer/src/views/settings/settings_controller.dart';
import 'package:catorganizer/src/views/settings/settings_view.dart';
import 'package:catorganizer/src/views/category/category_grid_view.dart';
import 'package:catorganizer/src/views/category/category_list_view.dart';
import 'package:catorganizer/src/views/category/category_detail_view.dart';
import 'package:catorganizer/src/views/document/document_new_view.dart';
import 'package:catorganizer/src/views/document/document_list_view.dart';
import 'package:catorganizer/src/views/document/document_in_category_list_view.dart';
import 'package:catorganizer/src/views/document/document_detail_view.dart';
import 'package:catorganizer/src/views/document/document_edit_view.dart';

/// The Widget that configures your application.
class Catorganizer extends StatelessWidget {
  const Catorganizer(
      {super.key, required this.settingsController, required this.manifest});

  final SettingsController settingsController;
  final ManifestModel manifest;

  @override
  Widget build(BuildContext context) {
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'categorizer',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [
            Locale('en', ''),
          ],

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web URL navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);

                  case CategoryListView.routeName:
                    return CategoryListView(
                      manifest: manifest,
                    );

                  case CategoryGridView.routeName:
                    return CategoryGridView(
                      manifest: manifest,
                    );

                  case CategoryDetailView.routeName:
                    return CategoryDetailView(
                      category: routeSettings.arguments as CategoryModel,
                    );

                  case DocumentListView.routeName:
                    return DocumentListView(
                      manifest: routeSettings.arguments as ManifestModel,
                    );

                  case DocumentInCategoryListView.routeName:
                    return DocumentInCategoryListView(
                      arguments: routeSettings.arguments
                          as DocumentInCategoryListViewArguments,
                    );

                  case DocumentDetailView.routeName:
                    return DocumentDetailView(
                      arguments: routeSettings.arguments
                          as DocumentDetailViewArguments,
                    );

                  case DocumentNewView.routeName:
                    return DocumentNewView(
                      arguments:
                          routeSettings.arguments as DocumentNewViewArguments,
                    );

                  case DocumentEditView.routeName:
                    return DocumentEditView(
                      arguments:
                          routeSettings.arguments as DocumentEditViewArguments,
                    );

                  default:
                    return CategoryGridView(
                      manifest: manifest,
                    );
                }
              },
            );
          },
        );
      },
    );
  }
}
