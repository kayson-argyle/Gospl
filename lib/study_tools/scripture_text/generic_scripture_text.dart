import 'package:flutter/material.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/study_tools/custom_selectable_text.dart';
import 'package:gospl/study_tools/display_highlight.dart';
import 'package:gospl/study_tools/glyph_data.dart';
import 'package:gospl/study_tools/highlight.dart';
import 'package:gospl/study_tools/highlightable_text.dart';
import 'package:flutter/rendering.dart';
import 'package:gospl/study_tools/text_box_painter.dart';
import 'package:intl/intl.dart';

class GenericScriptureText extends StatefulWidget {
  const GenericScriptureText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.locationString,
    required this.collection,
  });

  final TextStyle textStyle;
  final TextSpan text;
  final String locationString;
  final GenericCollection collection;

  @override
  State<GenericScriptureText> createState() => GenericScriptureTextState();
}

class GenericScriptureTextState extends State<GenericScriptureText> {
  double widgetWidth = 0;
  List<Highlight> savedHighlights = [];
  List<DisplayHighlight> savedDisplayHighlights = [];
  final String standardWork = 'The Book Of Mormon';
  final String book = '1 Nephi';
  final int chapter = 1;

  late TextSpanEditingController selectableTextController = TextSpanEditingController(text: widget.text);
  late FocusNode selectableTextFocusNode;

  final GlobalKey _key = GlobalKey();

  DisplayHighlight? currentlySelectedHighlight;
  DisplayHighlight? get getCurrentlySelectedHighlight => currentlySelectedHighlight;

  TextSelection previousTextSelection = const TextSelection(baseOffset: 0, extentOffset: 0);

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    selectableTextFocusNode.removeListener(() {});
    selectableTextFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    selectableTextFocusNode = FocusNode();
    selectableTextFocusNode.addListener(() {
      // if (!selectableTextFocusNode.hasFocus && currentlySelectedHighlight != null) {
      //   deselectSavedDisplayHighlight();
      // }
    });
    selectableTextController.addListener(() {
      if (selectableTextController.selection.isCollapsed && currentlySelectedHighlight != null) {
        deselectSavedDisplayHighlight();
      }
      previousTextSelection = selectableTextController.selection;
    });
  }

  void addPaintToSavedDisplayHighlights(Highlight highlight, TextBoxPainter textBoxPainter) {
    setState(() {
      savedDisplayHighlights.add(DisplayHighlight(
        textBoxPainter: textBoxPainter,
        highlight: highlight,
        onHighlightSelected: selectSavedDisplayHighlight,
      ));
    });
  }

  void selectSavedDisplayHighlight(DisplayHighlight displayHighlight) {
    if (displayHighlight.highlight.owner == isar.appUsers.getSync(0)!.name || !widget.collection.isCollaborative) {
      setState(() {
        savedDisplayHighlights.remove(displayHighlight);
      });
      if (currentlySelectedHighlight != null) {
        deselectSavedDisplayHighlight();
      }
      currentlySelectedHighlight = displayHighlight;
      selectableTextFocusNode.requestFocus();
      selectableTextController.selection = TextSelection(baseOffset: displayHighlight.highlight.start, extentOffset: displayHighlight.highlight.end);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectableTextFocusNode.hasFocus) {
          selectableTextController.showContextMenu();
        }
      });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            print(displayHighlight.highlight.owner);
            return Dialog(
                child: displayHighlight.highlight.note == ''
                    ? Container(
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: displayHighlight.highlight.owner, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' created this highlight '),
                                  TextSpan(
                                      text:
                                          ' on ${DateFormat.yMMMMd().format(displayHighlight.highlight.timeCreated)} at ${DateFormat.jm().format(displayHighlight.highlight.timeCreated)}.'),
                                  //TextSpan(text: 'at ${displayHighlight.highlight.timeCreated}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                            padding: const EdgeInsets.all(20),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text:
                                          'On ${DateFormat.yMMMMd().format(displayHighlight.highlight.timeCreated)} at ${DateFormat.jm().format(displayHighlight.highlight.timeCreated)} '),
                                  TextSpan(text: displayHighlight.highlight.owner, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' wrote:'),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: RichText(
                              text: TextSpan(
                                text: displayHighlight.highlight.note,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ));
          });
    }
  }

  void deselectSavedDisplayHighlight() {
    currentlySelectedHighlight!.highlight.start = previousTextSelection.start;
    currentlySelectedHighlight!.highlight.end = previousTextSelection.end;
    currentlySelectedHighlight!.updateSelection(previousTextSelection);

    setState(() {
      addPaintToSavedDisplayHighlights(currentlySelectedHighlight!.highlight, currentlySelectedHighlight!.textBoxPainter);
    });
    currentlySelectedHighlight = null;
  }

  void deleteCurrentlySelectedDisplayHighlight() {}

  void createHighlight(Highlight highlight) {}

  void loadHighlights(GlyphData glyphData) {}

  @override
  Widget build(BuildContext context) {
    EdgeInsets edgeInsets = const EdgeInsets.fromLTRB(20, 5, 20, 20);
    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          //paint the save highlights
          // ...savedDisplayHighlights,

          //the highlightable text
          GestureDetector(
            child: Container(
              padding: edgeInsets,
              child: HighlightableText(
                key: _key,
                selectableTextController: selectableTextController,
                focusNode: selectableTextFocusNode,
                locationString: widget.locationString,
                text: widget.text,
                textStyle: widget.textStyle,
                addPaintToSavedDisplayHighlights: addPaintToSavedDisplayHighlights,
                deleteCurrentlySelectedDisplayHighlight: deleteCurrentlySelectedDisplayHighlight,
                getCurrentlySelectedHighlight: getCurrentlySelectedHighlight,
                collection: widget.collection,
                createHighlight: createHighlight,
                loadHighlights: loadHighlights,
              ),
            ),
          ),

          TransparentPointer(
            transparent: true,
            child: Container(
              padding: edgeInsets,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...savedDisplayHighlights,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TransparentPointer extends SingleChildRenderObjectWidget {
  const TransparentPointer({
    Key? key,
    this.transparent = true,
    Widget? child,
  }) : super(key: key, child: child);

  final bool transparent;

  @override
  RenderTransparentPointer createRenderObject(BuildContext context) {
    return RenderTransparentPointer(
      transparent: transparent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransparentPointer renderObject) {
    renderObject.transparent = transparent;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('transparent', transparent));
  }
}

class RenderTransparentPointer extends RenderProxyBox {
  RenderTransparentPointer({
    RenderBox? child,
    bool transparent = true,
  })  : _transparent = transparent,
        super(child);

  bool get transparent => _transparent;
  bool _transparent;

  set transparent(bool value) {
    if (value == _transparent) return;
    _transparent = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // forward hits to our child:
    final hit = super.hitTest(result, position: position);
    // but report to our parent that we are not hit when `transparent` is true:
    return !transparent && hit;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('transparent', transparent));
  }
}
