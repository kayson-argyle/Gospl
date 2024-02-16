import "package:flutter/material.dart";

class HighlightMenuTextButton extends StatelessWidget {
  const HighlightMenuTextButton({super.key, required this.function, required this.text, this.icon});

  final Function function;
  final String text;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withAlpha(20), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10),
      child: InkWell(
          onTap: () {
            function();
          },
          child: icon == null
              ? Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                )
              : Column(
                  children: [
                    icon!,
                    Text(
                      text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )),
    );
  }
}
