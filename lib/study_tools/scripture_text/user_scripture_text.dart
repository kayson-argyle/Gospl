import 'package:flutter/material.dart';
import 'package:gospl/main.dart';
import 'package:gospl/study_tools/glyph_data.dart';
import 'package:gospl/study_tools/highlight.dart';
import 'package:gospl/study_tools/scripture_text/generic_scripture_text.dart';
import 'package:gospl/study_tools/text_box_painter.dart';
import 'package:isar/isar.dart';

class UserScriptureText extends GenericScriptureText {
  const UserScriptureText({super.key, required super.text, required super.textStyle, required super.locationString, required super.collection});

  @override
  State<GenericScriptureText> createState() => _UserScriptureTextState();
}

class _UserScriptureTextState extends GenericScriptureTextState {
  @override
  void deleteCurrentlySelectedDisplayHighlight() {
    if (currentlySelectedHighlight != null && currentlySelectedHighlight?.highlight != null) {
      isar.writeTxn(() async {
        isar.highlights.delete(currentlySelectedHighlight!.highlight.id!);
        setState(() {
          currentlySelectedHighlight = null;
        });
        selectableTextController.selection = const TextSelection(baseOffset: 0, extentOffset: 0);
        selectableTextController.hideContextMenu();
      });
    }
  }

  @override
  Future<Highlight> createHighlight(Highlight highlight) async {
    await isar.writeTxn(() async {
      isar.highlights.put(highlight);
    });
    return highlight;
  }

  @override
  void loadHighlights(GlyphData glyphData) async {
    
    final List<Highlight> chapterHighlights = await isar.highlights.filter().locationEqualTo(widget.locationString).collectionIdEqualTo(widget.collection.id!).findAll();
    for (Highlight highlight in chapterHighlights) {
      addPaintToSavedDisplayHighlights(
          highlight, TextBoxPainter(selection: TextSelection(baseOffset: highlight.start, extentOffset: highlight.end), color: Color(highlight.color), glyphData: glyphData));
    }
  }
}
