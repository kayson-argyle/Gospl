import "package:flutter/material.dart";
import "package:gospl/main.dart";

class HighlightButton extends StatelessWidget {
  const HighlightButton({super.key, required this.function, required this.color});

  final Function function;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        preferences.setInt('mostRecentHighlightColor', color.value);
        function(color);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration:  BoxDecoration(
          border: Border.all(color: Colors.black.withAlpha(100), width: 2),
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [color.withAlpha(1), color],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: const SizedBox(
          width: 15,
          height: 15,
        ),
      ),
    );
  }
}
