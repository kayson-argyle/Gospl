import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gospl/collection_stuff/generic_collection.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/study_tools/custom_selectable_text.dart';
import 'package:gospl/study_tools/display_highlight.dart';
import 'package:gospl/study_tools/glyph_data.dart';
import 'package:gospl/study_tools/highlight.dart';
import 'package:gospl/study_tools/highlighted_text_context_menu/highlight_button_menu.dart';
import 'package:gospl/study_tools/highlighted_text_context_menu/highlight_menu_text_button.dart';
import 'package:gospl/study_tools/note_screen.dart';
import 'package:gospl/study_tools/text_box_painter.dart';
import 'package:gospl/main.dart';

class HighlightableText extends StatefulWidget {
  const HighlightableText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.addPaintToSavedDisplayHighlights,
    required this.locationString,
    required this.focusNode,
    required this.selectableTextController,
    required this.deleteCurrentlySelectedDisplayHighlight,
    required this.getCurrentlySelectedHighlight,
    required this.collection,
    required this.createHighlight,
    required this.loadHighlights,
  });

  final TextSpan text;
  final TextStyle textStyle;
  final Function addPaintToSavedDisplayHighlights;
  final String locationString;
  final FocusNode focusNode;
  final TextSpanEditingController selectableTextController;
  final Function deleteCurrentlySelectedDisplayHighlight;
  final DisplayHighlight? getCurrentlySelectedHighlight;
  final GenericCollection collection;
  final Function createHighlight;
  final Function loadHighlights;

  @override
  State<HighlightableText> createState() => _HighlightableTextState();
}

class _HighlightableTextState extends State<HighlightableText> {
  late GlyphData glyphData;
  late TextSpanEditingController selectableTextController = widget.selectableTextController;
  TextSelection currentTextSelection = const TextSelection(baseOffset: 0, extentOffset: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      RenderBox renderBox = (widget.key as GlobalKey).currentContext!.findRenderObject() as RenderBox;
      double renderBoxWidth = renderBox.size.width;
      glyphData = GlyphData(style: widget.textStyle, text: widget.text, width: renderBoxWidth - 1);
      widget.loadHighlights(glyphData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(selectionHandleColor: Colors.red.withAlpha(100)),
      ),
      child: CustomSelectableText.rich(
          controller: selectableTextController,
          showCursor: false,
          maxLines: null,
          autofocus: true,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          focusNode: widget.focusNode,
          magnifierConfiguration: TextMagnifierConfiguration.disabled,
          textHeightBehavior: const TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even),
          contextMenuBuilder: (context, editableTextState) {
            return Material(
              elevation: 0,
              type: MaterialType.transparency,
              textStyle: TextStyle(fontSize: 40, color: Colors.black.withAlpha(100)),
              child: HighlightMenu(
                  widget: widget,
                  currentTextSelection: currentTextSelection,
                  glyphData: glyphData,
                  selectableTextController: selectableTextController,
                  editableTextState: editableTextState),
            );
          },
          cursorWidth: 0,
          cursorHeight: 0,
          textScaler: TextScaler.noScaling,
          cursorRadius: const Radius.circular(0),
          //selectionControls: null,
          textAlign: TextAlign.left,
          style: widget.textStyle.copyWith(height: (widget.textStyle.height! * 0.95)),
          onSelectionChanged: (TextSelection textSelection, selectionChangedCause) {
            currentTextSelection = textSelection;
          }),
    );
  }
}

class HighlightMenu extends StatelessWidget {
  const HighlightMenu({
    super.key,
    required this.widget,
    required this.currentTextSelection,
    required this.glyphData,
    required this.selectableTextController,
    required this.editableTextState,
  });

  final HighlightableText widget;
  final TextSelection currentTextSelection;
  final GlyphData glyphData;
  final TextSpanEditingController selectableTextController;
  final EditableTextState editableTextState;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextSelectionToolbar(
      anchorAbove: editableTextState.contextMenuAnchors.primaryAnchor,
      anchorBelow:
          editableTextState.contextMenuAnchors.secondaryAnchor == null ? editableTextState.contextMenuAnchors.primaryAnchor : editableTextState.contextMenuAnchors.secondaryAnchor!,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 12, 8.0, 0),
              child: HighlightButtonMenu(
                function: (color) async {
                  if (widget.getCurrentlySelectedHighlight == null) {
                    Highlight highlight = Highlight(
                      start: currentTextSelection.start,
                      end: currentTextSelection.end,
                      color: color.value,
                      location: widget.locationString,
                      collectionId: widget.collection.id!,
                      isCollaborative: widget.collection.isCollaborative,
                      timeCreated: DateTime.now(),
                      owner: isar.appUsers.getSync(0)!.name,
                    );
                    highlight = await widget.createHighlight(highlight);
                    widget.addPaintToSavedDisplayHighlights(highlight, TextBoxPainter(selection: currentTextSelection, color: color, glyphData: glyphData));
                  } else {
                    widget.getCurrentlySelectedHighlight?.updateColor(color);
                  }
                  selectableTextController.hideContextMenu();
                  selectableTextController.selection = const TextSelection(baseOffset: 0, extentOffset: 0);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 16, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightMenuTextButton(
                    function: () async {
                      DisplayHighlight? currentlySelectedHighlight = widget.getCurrentlySelectedHighlight;
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NoteScreen(
                                  text: widget.getCurrentlySelectedHighlight != null ? widget.getCurrentlySelectedHighlight!.highlight.note : '',
                                )),
                      );
                      if (result != '') {
                        if (currentlySelectedHighlight == null) {
                          //make a new highlight if there isnt one
                          Highlight highlight = Highlight(
                            start: currentTextSelection.start,
                            end: currentTextSelection.end,
                            color: preferences.getInt('mostRecentHighlightColor')!,
                            location: widget.locationString,
                            note: result,
                            collectionId: widget.collection.id!,
                            isCollaborative: widget.collection.isCollaborative,
                            timeCreated: DateTime.now(),
                            owner: isar.appUsers.getSync(0)!.name,
                          );
                          widget.addPaintToSavedDisplayHighlights(
                              highlight, TextBoxPainter(selection: currentTextSelection, color: Color(preferences.getInt('mostRecentHighlightColor')!), glyphData: glyphData));
                          widget.createHighlight(highlight);
                          selectableTextController.hideContextMenu();
                          selectableTextController.selection = const TextSelection(baseOffset: 0, extentOffset: 0);
                        } else {
                          //otherwise update the current highlight
                          currentlySelectedHighlight.updateNote(result);
                        }
                      } else if (currentlySelectedHighlight != null) {
                        //if the result is nothing but currently selected highlight is active, delete the note text (update the note to nothing)
                        currentlySelectedHighlight.updateNote(result);
                      }
                    },
                    text: 'Note',
                    icon: Icon(
                      Icons.note_outlined,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  HighlightMenuTextButton(
                    function: () {},
                    text: 'Copy',
                    icon: Icon(
                      Icons.copy,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  HighlightMenuTextButton(
                    function: () {
                      widget.deleteCurrentlySelectedDisplayHighlight();
                    },
                    text: 'Delete',
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
