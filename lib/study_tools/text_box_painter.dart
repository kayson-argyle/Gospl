import 'package:flutter/material.dart';
import 'package:gospl/study_tools/glyph_data.dart';

class TextBoxPainter extends CustomPainter {
  late List<TextBox> textBoxes;
  Color color;
  final GlyphData glyphData;
  final TextSelection selection;

  TextBoxPainter({required this.color, required this.glyphData, required this.selection}) {
    textBoxes = glyphData.getTextBoxes(
      selection: TextSelection(baseOffset: selection.start, extentOffset: selection.end),
    ) ?? [];
  }

  void setSelection(TextSelection selection) {
    selection = selection;
    textBoxes = glyphData.getTextBoxes(
      selection: TextSelection(baseOffset: selection.start, extentOffset: selection.end),
    ) ?? [];
  }

  double getHeight() {
    return glyphData.getHeight();
  }
  
  @override
  bool? hitTest(Offset position) {
    for (final box in textBoxes) {
      if (box.toRect().contains(position)){
        return true;
      }
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final box in textBoxes) {
      paint.color = color.withAlpha(100);
      canvas.drawRect(box.toRect(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}