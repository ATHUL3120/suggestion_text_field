
# SuggestionTextField

SuggestionTextField is a Flutter package that provides a text field with auto-suggestion feature. It's useful for scenarios where users need to input data from a predefined list.

## Installation

To use SuggestionTextField, add it to your dependencies in `pubspec.yaml`:
```dart
dependencies :  
  suggestion_text_field : ^1.0.5
```

## Usage

Simply import the package and use the `SuggestionTextField` widget in your Flutter app. Here is an example:

```dart  
import 'package:suggestion_input_field/suggestion_input_field.dart';  
  
List<MapEntry> list=[];  
  
MapEntry? mapEntry;  
  
SuggestionTextField<MapEntry>(  
 value: mapEntry, textFieldContent: TextFieldContent( label: 'Map Entry Details',  ),  
 suggestionFetch:(textEditingValue) async{  
  return list;  },  
 onClose: () {  
 mapEntry=null; setState(() {  
  
 });  
  },  
);  
```  

## Example

[click here](https://github.com/ChegzDev/suggestion_input_field/tree/master/example/lib) for example


## Issues and feedback

Please file issues and feedback using the Github issues page for this repository.

If you have any suggestions or feedback, please send an email to __chegz.dev@gmail.com__ and we'll be happy to hear from you!