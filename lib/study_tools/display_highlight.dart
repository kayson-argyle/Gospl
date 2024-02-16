import 'package:flutter/material.dart';
import 'package:gospl/main.dart';
import 'package:gospl/study_tools/highlight.dart';
import 'package:gospl/study_tools/text_box_painter.dart';

class DisplayHighlight extends StatelessWidget {
  const DisplayHighlight({super.key, required this.textBoxPainter, required this.highlight, required this.onHighlightSelected});

  final TextBoxPainter textBoxPainter;
  final Highlight highlight;
  final Function onHighlightSelected;

  void updateColor(Color color) {
    textBoxPainter.color = color;
    highlight.color = color.value;
    writeToDatabase();
  }

  void updateSelection(TextSelection selection) {
    if (selection.start != textBoxPainter.selection.start || selection.end != textBoxPainter.selection.end) {
      textBoxPainter.setSelection(selection);
      highlight.start = selection.start;
      highlight.end = selection.end;
      writeToDatabase();
    }
  }

  void updateNote(String note) {
    highlight.note = note;
    writeToDatabase();
  }

  void writeToDatabase() async {
    if (highlight.isCollaborative) {
      firestore.doc(highlight.firestoreScriptureCollectionDocumentId).collection('highlights').doc(highlight.firestoreId).set(highlight.toMap());
    } else {
      await isar.writeTxn(() async {
        isar.highlights.put(highlight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //behavior: HitTestBehavior.translucent,
      onTap: () {
        onHighlightSelected(this);
      },
      child: Stack(clipBehavior: Clip.none, children: [
        CustomPaint(
          painter: textBoxPainter,
          size: Size(500, textBoxPainter.getHeight()),
        ),
        highlight.note == ""
            ? Container()
            : Positioned(
                left: textBoxPainter.textBoxes[textBoxPainter.textBoxes.length - 1].right - 6,
                top: textBoxPainter.textBoxes[textBoxPainter.textBoxes.length - 1].bottom - 6,
                child: Icon(
                  Icons.sticky_note_2_outlined,
                  color: Color(highlight.color).withAlpha(150),
                  size: 18,
                ),
              ),
      ]),
    );
  }
}
