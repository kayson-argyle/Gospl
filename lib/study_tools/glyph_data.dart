import 'package:flutter/material.dart';

class GlyphData {
  GlyphData ({required this.style, required this.text, required this.width}) {
    tp.layout(maxWidth: width);
  }
  final double width;
  final TextStyle style;
  final TextSpan text;
  late TextPainter tp = TextPainter(text: text, textDirection: TextDirection.ltr, strutStyle: StrutStyle.fromTextStyle(style));
  
  Offset getPosition ({required int location}) {
    return tp.getOffsetForCaret(TextPosition(offset: location), Rect.zero);
  }
  
  double getHeight() {
    return tp.height;
  }

  List<TextBox>? getTextBoxes({required TextSelection selection}){
    return tp.getBoxesForSelection(selection);
  }
}