library suggestion_input_field;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

class TextFieldContent {
  final bool isPrimarySelect = false;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final FocusNode? focusNode;
  final String? label;
  //final InputDecoration? decoration;
  final void Function()? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final AutovalidateMode? autoValidateMode;
  final void Function(String)? onFieldSubmitted;

  TextFieldContent(
      {this.onChanged,
        this.onSaved,
        this.focusNode,
        this.label,
        this.onEditingComplete,
        this.inputFormatters,
        this.textInputAction,
        this.validator,
        this.maxLines = 1,
        this.keyboardType,
        this.autoValidateMode,
        this.onFieldSubmitted});
}

class SuggestionTextField<T extends Object> extends StatelessWidget {
  ///sample code:
  ///
  /// CustAutocomplete<ModelClass>(
  ///
  ///   value: model as ModelClass?,
  ///
  ///   optionsBuilder: (text) async {
  ///     return await loadModelClassWithFilter(text);
  ///   },
  ///
  ///   autoCompleteField: AutoCompleteField(
  ///     label: "Item Name",
  ///   ),
  ///   displayStringForOption: (value) =>value.name,
  ///   itemBuilder: (ItemsM item) {
  ///     return ListTile(
  ///       title: Text(item.name),
  ///       subtitle:Text(item.mobile),
  ///     );
  ///   },
  ///   onSelected: (value) async{
  ///     model=value
  ///     setState((){});
  ///   },
  /// );
  SuggestionTextField(
      {super.key,
        required this.suggestionFetch,
        this.displayStringForOption = RawSuggestionField.defaultStringForOption,
        this.onSelected,
        this.optionsMaxHeight = 200.0,
        this.optionsMaxWidth = 300.0,
        this.itemBuilder,
        this.value,
        this.textFieldContent,
        this.readOnly = false,
        this.firstSuggestionFocus=true,
        this.onClose
      });

  final bool readOnly;

  final bool firstSuggestionFocus;

  final Widget Function(
      T item,
      )? itemBuilder;
  final AutocompleteOptionToString<T> displayStringForOption;
  final T? value;

  final void Function()? onClose;

  /// {@macro flutter.widgets.RawAutocomplete.fieldViewBuilder}
  ///
  /// If not provided, will build a standard Material-style text field by
  /// default.
  final TextFieldContent? textFieldContent;
  final AutocompleteOnSelected<T>? onSelected;

  /// list your content with filter
  final AutocompleteOptionsBuilder<T> suggestionFetch;

  final double optionsMaxHeight;
  final double optionsMaxWidth;

  /// {@macro flutter.widgets.RawAutocomplete.initialValue}
  final TextEditingController controller= TextEditingController();
  final FocusNode focusNode= FocusNode();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(value!=null){
        controller.text= displayStringForOption(value!);
      }
    });
    return RawSuggestionField<T>(
      displayStringForOption: displayStringForOption,
      firstSuggestionFocus: firstSuggestionFocus,
      fieldViewBuilder:
          (context, textEditingController, focusNodes, onFieldSubmitted) {
        return TextFormField(
          readOnly: readOnly,
          controller: textEditingController,
          onFieldSubmitted: (p0) {
            if (textFieldContent?.onFieldSubmitted != null) {
              textFieldContent?.onFieldSubmitted!(p0);
            }
            onFieldSubmitted();
          },
          focusNode: focusNodes,
          validator: textFieldContent?.validator,
          onEditingComplete: textFieldContent?.onEditingComplete,
          textInputAction: textFieldContent?.textInputAction,
          keyboardType: textFieldContent?.keyboardType,
          onChanged: (value) {
            if(textFieldContent?.onChanged!=null){
              textFieldContent!.onChanged!(value);
            }
          },
          onSaved: textFieldContent?.onSaved,
          maxLines: textFieldContent?.maxLines ?? 1,
          autovalidateMode: textFieldContent?.autoValidateMode,
          inputFormatters: textFieldContent?.inputFormatters,
          decoration: InputDecoration(
              labelText: textFieldContent?.label,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: onClose!=null?InkWell(onTap:  onClose, child: const Icon(Icons.close,size: 20,),):null,
              isDense: true,
              floatingLabelAlignment: FloatingLabelAlignment.start),
        );
      },
      optionsBuilder: (textEditingValue) async{
        final d = await suggestionFetch(textEditingValue);
        return d;
      },
      focusNode: textFieldContent?.focusNode ?? focusNode,
      textEditingController: controller,
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
        return _Suggestions<T>(
          displayStringForOption: displayStringForOption,
          onSelected: onSelected,
          options: options,
          maxWidth: optionsMaxWidth,
          maxOptionsHeight: optionsMaxHeight,
          itemBuilder: itemBuilder,
        );
      },
      onSelected: onSelected,
    );
  }
}

class _Suggestions<T extends Object> extends StatelessWidget {
  const _Suggestions({
    super.key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
    this.itemBuilder,
    this.maxWidth,
  });
  final Widget Function(T item)? itemBuilder;
  final AutocompleteOptionToString<T> displayStringForOption;
  final double? maxWidth;
  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: maxOptionsHeight, maxWidth: maxWidth ?? 300),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  onSelected(option);
                },
                child: Builder(builder: (BuildContext context) {
                  final bool highlight =
                      AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance
                        .addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding:
                    itemBuilder == null ? const EdgeInsets.all(16.0) : null,
                    child: itemBuilder == null
                        ? Text(displayStringForOption(option))
                        : itemBuilder!(option),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
class RawSuggestionField<T extends Object> extends StatefulWidget {
  /// Create an instance of RawAutocomplete.
  ///
  /// [displayStringForOption], [optionsBuilder] and [optionsViewBuilder] must
  /// not be null.
  const RawSuggestionField({
    super.key,
    required this.optionsViewBuilder,
    required this.optionsBuilder,
    this.displayStringForOption = defaultStringForOption,
    this.fieldViewBuilder,
    this.focusNode,
    this.onSelected,
    this.textEditingController,
    this.firstSuggestionFocus=true,
    this.initialValue,
  }) : assert(
  fieldViewBuilder != null
      || (key != null && focusNode != null && textEditingController != null),
  'Pass in a fieldViewBuilder, or otherwise create a separate field and pass in the FocusNode, TextEditingController, and a key. Use the key with RawAutocomplete.onFieldSubmitted.',
  ),
        assert((focusNode == null) == (textEditingController == null)),
        assert(
        !(textEditingController != null && initialValue != null),
        'textEditingController and initialValue cannot be simultaneously defined.',
        );

  /// {@template flutter.widgets.RawAutocomplete.fieldViewBuilder}
  /// Builds the field whose input is used to get the options.
  ///
  /// Pass the provided [TextEditingController] to the field built here so that
  /// RawAutocomplete can listen for changes.
  /// {@endtemplate}
  final AutocompleteFieldViewBuilder? fieldViewBuilder;

  final bool firstSuggestionFocus;

  /// The [FocusNode] that is used for the text field.
  ///
  /// {@template flutter.widgets.RawAutocomplete.split}
  /// The main purpose of this parameter is to allow the use of a separate text
  /// field located in another part of the widget tree instead of the text
  /// field built by [fieldViewBuilder]. For example, it may be desirable to
  /// place the text field in the AppBar and the options below in the main body.
  ///
  /// When following this pattern, [fieldViewBuilder] can return
  /// `SizedBox.shrink()` so that nothing is drawn where the text field would
  /// normally be. A separate text field can be created elsewhere, and a
  /// FocusNode and TextEditingController can be passed both to that text field
  /// and to RawAutocomplete.
  ///
  /// {@tool dartpad}
  /// This examples shows how to create an autocomplete widget with the text
  /// field in the AppBar and the results in the main body of the app.
  ///
  /// ** See code in examples/api/lib/widgets/autocomplete/raw_autocomplete.focus_node.0.dart **
  /// {@end-tool}
  /// {@endtemplate}
  ///
  /// If this parameter is not null, then [textEditingController] must also be
  /// not null.
  final FocusNode? focusNode;

  /// {@template flutter.widgets.RawAutocomplete.optionsViewBuilder}
  /// Builds the selectable options widgets from a list of options objects.
  ///
  /// The options are displayed floating below the field using a
  /// [CompositedTransformFollower] inside of an [Overlay], not at the same
  /// place in the widget tree as [RawSuggestionField].
  ///
  /// In order to track which item is highlighted by keyboard navigation, the
  /// resulting options will be wrapped in an inherited
  /// [AutocompleteHighlightedOption] widget.
  /// Inside this callback, the index of the highlighted option can be obtained
  /// from [AutocompleteHighlightedOption.of] to display the highlighted option
  /// with a visual highlight to indicate it will be the option selected from
  /// the keyboard.
  ///
  /// {@endtemplate}
  final AutocompleteOptionsViewBuilder<T> optionsViewBuilder;

  /// {@template flutter.widgets.RawAutocomplete.displayStringForOption}
  /// Returns the string to display in the field when the option is selected.
  ///
  /// This is useful when using a custom T type and the string to display is
  /// different than the string to search by.
  ///
  /// If not provided, will use `option.toString()`.
  /// {@endtemplate}
  final AutocompleteOptionToString<T> displayStringForOption;

  /// {@template flutter.widgets.RawAutocomplete.onSelected}
  /// Called when an option is selected by the user.
  ///
  /// Any [TextEditingController] listeners will not be called when the user
  /// selects an option, even though the field will update with the selected
  /// value, so use this to be informed of selection.
  /// {@endtemplate}
  final AutocompleteOnSelected<T>? onSelected;

  /// {@template flutter.widgets.RawAutocomplete.optionsBuilder}
  /// A function that returns the current selectable options objects given the
  /// current TextEditingValue.
  /// {@endtemplate}
  final AutocompleteOptionsBuilder<T> optionsBuilder;

  /// The [TextEditingController] that is used for the text field.
  ///
  /// {@macro flutter.widgets.RawAutocomplete.split}
  ///
  /// If this parameter is not null, then [focusNode] must also be not null.
  final TextEditingController? textEditingController;

  /// {@template flutter.widgets.RawAutocomplete.initialValue}
  /// The initial value to use for the text field.
  /// {@endtemplate}
  ///
  /// Setting the initial value does not notify [textEditingController]'s
  /// listeners, and thus will not cause the options UI to appear.
  ///
  /// This parameter is ignored if [textEditingController] is defined.
  final TextEditingValue? initialValue;

  /// Calls [AutocompleteFieldViewBuilder]'s onFieldSubmitted callback for the
  /// RawAutocomplete widget indicated by the given [GlobalKey].
  ///
  /// This is not typically used unless a custom field is implemented instead of
  /// using [fieldViewBuilder]. In the typical case, the onFieldSubmitted
  /// callback is passed via the [AutocompleteFieldViewBuilder] signature. When
  /// not using fieldViewBuilder, the same callback can be called by using this
  /// static method.
  ///
  /// See also:
  ///
  ///  * [focusNode] and [textEditingController], which contain a code example
  ///    showing how to create a separate field outside of fieldViewBuilder.
  static void onFieldSubmitted<T extends Object>(GlobalKey key) {
    final _RawSuggestionFieldState<T> rawAutocomplete = key.currentState! as _RawSuggestionFieldState<T>;
    rawAutocomplete._onFieldSubmitted();
  }

  /// The default way to convert an option to a string in
  /// [displayStringForOption].
  ///
  /// Simply uses the `toString` method on the option.
  static String defaultStringForOption(dynamic option) {
    return option.toString();
  }

  @override
  State<RawSuggestionField<T>> createState() => _RawSuggestionFieldState<T>();
}

class _RawSuggestionFieldState<T extends Object> extends State<RawSuggestionField<T>> {
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _optionsLayerLink = LayerLink();
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  late final Map<Type, Action<Intent>> _actionMap;
  late final _SuggestionCallbackAction<AutocompletePreviousOptionIntent> _previousOptionAction;
  late final _SuggestionCallbackAction<AutocompleteNextOptionIntent> _nextOptionAction;
  late final _SuggestionCallbackAction<DismissIntent> _hideOptionsAction;
  Iterable<T> _options = Iterable<T>.empty();
  T? _selection;
  bool _userHidOptions = false;
  String _lastFieldText = '';
  final ValueNotifier<int> _highlightedOptionIndex = ValueNotifier<int>(0);

  static const Map<ShortcutActivator, Intent> _shortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp): AutocompletePreviousOptionIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown): AutocompleteNextOptionIntent(),
  };

  // The OverlayEntry containing the options.
  OverlayEntry? _floatingOptions;

  // True iff the state indicates that the options should be visible.
  bool get _shouldShowOptions {
    return !_userHidOptions && _focusNode.hasFocus && _selection == null && _options.isNotEmpty;
  }

  // Called when _textEditingController changes.
  Future<void> _onChangedField() async {
    final TextEditingValue value = _textEditingController.value;
    final Iterable<T> options = await widget.optionsBuilder(
      value,
    );
    _options = options;
    if(widget.firstSuggestionFocus){
      _updateHighlight(_highlightedOptionIndex.value);
    }else{
      _highlightedOptionIndex.value=-1;
    }
    //
    if (_selection != null
        && value.text != widget.displayStringForOption(_selection!)) {
      _selection = null;
    }

    // Make sure the options are no longer hidden if the content of the field
    // changes (ignore selection changes).
    if (value.text != _lastFieldText) {
      _userHidOptions = false;
      _lastFieldText = value.text;
    }
    _updateActions();
    _updateOverlay();
  }

  // Called when the field's FocusNode changes.
  void _onChangedFocus() {
    // Options should no longer be hidden when the field is re-focused.
    _userHidOptions = !_focusNode.hasFocus;
    _updateActions();
    _updateOverlay();
  }

  // Called from fieldViewBuilder when the user submits the field.
  void _onFieldSubmitted() {
    if (_options.isEmpty || _userHidOptions) {
      return;
    }
    if(_highlightedOptionIndex.value!=-1){
      _select(_options.elementAt(_highlightedOptionIndex.value));
    }

  }

  // Select the given option and update the widget.
  void _select(T nextSelection) {
    if (nextSelection == _selection) {
      return;
    }
    _selection = nextSelection;
    final String selectionString = widget.displayStringForOption(nextSelection);
    _textEditingController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: selectionString.length),
      text: selectionString,
    );
    _updateActions();
    _updateOverlay();
    widget.onSelected?.call(_selection!);
  }

  void _updateHighlight(int newIndex) {
    _highlightedOptionIndex.value = _options.isEmpty ? 0 : newIndex % _options.length;
  }

  void _highlightPreviousOption(AutocompletePreviousOptionIntent intent) {
    if (_userHidOptions) {
      _userHidOptions = false;
      _updateActions();
      _updateOverlay();
      return;
    }
    if(_highlightedOptionIndex.value==0){
      _highlightedOptionIndex.value=-1;
    }else{
      _updateHighlight(_highlightedOptionIndex.value - 1);
    }

  }

  void _highlightNextOption(AutocompleteNextOptionIntent intent) {
    if (_userHidOptions) {
      _userHidOptions = false;
      _updateActions();
      _updateOverlay();
      return;
    }
    _updateHighlight(_highlightedOptionIndex.value + 1);
  }

  Object? _hideOptions(DismissIntent intent) {
    if (!_userHidOptions) {
      _userHidOptions = true;
      _updateActions();
      _updateOverlay();
      return null;
    }
    return Actions.invoke(context, intent);
  }

  void _setActionsEnabled(bool enabled) {
    // The enabled state determines whether the action will consume the
    // key shortcut or let it continue on to the underlying text field.
    // They should only be enabled when the options are showing so shortcuts
    // can be used to navigate them.
    _previousOptionAction.enabled = enabled;
    _nextOptionAction.enabled = enabled;
    _hideOptionsAction.enabled = enabled;
  }

  void _updateActions() {
    _setActionsEnabled(_focusNode.hasFocus && _selection == null && _options.isNotEmpty);
  }

  bool _floatingOptionsUpdateScheduled = false;
  // Hide or show the options overlay, if needed.
  void _updateOverlay() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      if (!_floatingOptionsUpdateScheduled) {
        _floatingOptionsUpdateScheduled = true;
        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
          _floatingOptionsUpdateScheduled = false;
          _updateOverlay();
        });
      }
      return;
    }

    _floatingOptions?.remove();
    if (_shouldShowOptions) {
      final OverlayEntry newFloatingOptions = OverlayEntry(
        builder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _optionsLayerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            child: TextFieldTapRegion(
              child: AutocompleteHighlightedOption(
                  highlightIndexNotifier: _highlightedOptionIndex,
                  child: Builder(
                      builder: (BuildContext context) {
                        return widget.optionsViewBuilder(context, _select, _options);
                      }
                  )
              ),
            ),
          );
        },
      );
      Overlay.of(context, rootOverlay: true, debugRequiredFor: widget).insert(newFloatingOptions);
      _floatingOptions = newFloatingOptions;
    } else {
      _floatingOptions = null;
    }
  }

  // Handle a potential change in textEditingController by properly disposing of
  // the old one and setting up the new one, if needed.
  void _updateTextEditingController(TextEditingController? old, TextEditingController? current) {
    if ((old == null && current == null) || old == current) {
      return;
    }
    if (old == null) {
      _textEditingController.removeListener(_onChangedField);
      _textEditingController.dispose();
      _textEditingController = current!;
    } else if (current == null) {
      _textEditingController.removeListener(_onChangedField);
      _textEditingController = TextEditingController();
    } else {
      _textEditingController.removeListener(_onChangedField);
      _textEditingController = current;
    }
    _textEditingController.addListener(_onChangedField);
  }

  // Handle a potential change in focusNode by properly disposing of the old one
  // and setting up the new one, if needed.
  void _updateFocusNode(FocusNode? old, FocusNode? current) {
    if ((old == null && current == null) || old == current) {
      return;
    }
    if (old == null) {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode.dispose();
      _focusNode = current!;
    } else if (current == null) {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode = FocusNode();
    } else {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode = current;
    }
    _focusNode.addListener(_onChangedFocus);
    _focusNode.unfocus();
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.textEditingController ?? TextEditingController.fromValue(widget.initialValue);
    _textEditingController.addListener(_onChangedField);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onChangedFocus);
    _previousOptionAction = _SuggestionCallbackAction<AutocompletePreviousOptionIntent>(onInvoke: _highlightPreviousOption);
    _nextOptionAction = _SuggestionCallbackAction<AutocompleteNextOptionIntent>(onInvoke: _highlightNextOption);
    _hideOptionsAction = _SuggestionCallbackAction<DismissIntent>(onInvoke: _hideOptions);
    _actionMap = <Type, Action<Intent>> {
      AutocompletePreviousOptionIntent: _previousOptionAction,
      AutocompleteNextOptionIntent: _nextOptionAction,
      DismissIntent: _hideOptionsAction,
    };
    _updateActions();
    _updateOverlay();
  }

  @override
  void didUpdateWidget(RawSuggestionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTextEditingController(
      oldWidget.textEditingController,
      widget.textEditingController,
    );
    _updateFocusNode(oldWidget.focusNode, widget.focusNode);
    _updateActions();
    _updateOverlay();
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onChangedField);
    if (widget.textEditingController == null) {
      _textEditingController.dispose();
    }
    _focusNode.removeListener(_onChangedFocus);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _floatingOptions?.remove();
    _floatingOptions = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldTapRegion(
      child: Container(
        key: _fieldKey,
        child: Shortcuts(
          shortcuts: _shortcuts,
          child: Actions(
            actions: _actionMap,
            child: CompositedTransformTarget(
              link: _optionsLayerLink,
              child: widget.fieldViewBuilder == null
                  ? const SizedBox.shrink()
                  : widget.fieldViewBuilder!(
                context,
                _textEditingController,
                _focusNode,
                _onFieldSubmitted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionCallbackAction<T extends Intent> extends CallbackAction<T> {
  _SuggestionCallbackAction({
    required super.onInvoke,
    this.enabled = true,
  });

  bool enabled;

  @override
  bool isEnabled(covariant T intent) => enabled;

  @override
  bool consumesKey(covariant T intent) => enabled;
}
