import 'package:flutter/material.dart';

class FauxUpperCaseText extends StatelessWidget {
  const FauxUpperCaseText({
    super.key,
    required this.text,
    this.style = const TextStyle(),
    this.fontSize = 16,
  });

  final String text;
  final TextStyle style;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: text.split(' ').map((word) {
          return TextSpan(
            children: [
              TextSpan(
                text: word.substring(0, 1).toUpperCase(),
                style: style.copyWith(
                  fontSize: fontSize * 1.2, // Larger size for first letter
                ),
              ),
              TextSpan(
                text: word.substring(1).toUpperCase(),
                style: style.copyWith(
                  fontSize: fontSize,
                ),
              ),
              const TextSpan(text: ' '),
            ],
          );
        }).toList(),
      ),
    );
  }
}
