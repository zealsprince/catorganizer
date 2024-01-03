# catorganizer

_Organize and find files real fast_

Catorganizer is an organization application built with simplicity in mind. The user interface focuses on creating a shallow and rigid nesting structure for documents to avoid mislabeling and information paralysis leading to miscategorization and effectively loss of information.

The application has customizability in mind but does not allow changing it during runtime. Instead, it is configured using a simple directory structure and `manifest.json` file. The goal is to avoid customizing to new use cases after being configured, as such would increase organizational complexity.

## Building ##

The application uses [Flutter](https://flutter.dev/) as its UI framework and as such runs on [Dart](https://dart.dev/).

To build the application you will need both to be installed on your local system. After which you will need to install the project dependencies by running the following command in the project's root directory.

  $ flutter pub get

From there, you can build the application.

  $ flutter build [windows|macos|linux]

## Development ##

To run the application locally from source you can run the follow command. Make sure you have installed dependencies beforehand though, just like with the build process.

  $ flutter run
