# SuggestionTextField

SuggestionTextField is a Flutter package that provides a text field with auto-suggestion feature. It's useful for scenarios where users need to input data from a predefined list.

## Installation

To use this package, add `suggestion_text_field` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

## Usage

Simply import the package and use the `SuggestionTextField` widget in your Flutter app. Here is an example:

```dart
import 'package:suggestion_text_field/suggestion_text_field.dart';

List<MapEntry> list=[];

MapEntry? mapEntry;

SuggestionTextField<MapEntry>(
  value: mapEntry,
  textFieldContent: TextFieldContent(
    label: 'Map Entry Details',
  ),
  suggestionFetch:(textEditingValue) async{
    return list;
  },
  onClose: () {
    mapEntry=null;
    setState(() {

    });
  },
);