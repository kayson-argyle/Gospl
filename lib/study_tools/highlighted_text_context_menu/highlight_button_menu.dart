import 'package:flutter/material.dart';
import 'package:gospl/study_tools/highlighted_text_context_menu/highlight_button.dart';

class HighlightButtonMenu extends StatelessWidget {
  const HighlightButtonMenu({super.key, required this.function});

  final Function function;
  static List<Color> colors = [const Color(0xFFE5977B), const Color(0xFFfffdf6), const Color(0xFFffba4d), const Color(0xFF7698b2), const Color(0xFFb5747a)];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 5; i++) ...[HighlightButton(function: function, color: colors[i]), const SizedBox(width: 5)]
      ],
    );
  }
}