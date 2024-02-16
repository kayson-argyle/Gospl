import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {

  const NoteScreen({super.key, this.text = ''});
  final String text;
  

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController()..text = text;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
                      // Replace 'YourString' with the actual string you want to return
                      Navigator.pop(context, controller.text);
                    },
            icon: const Icon(Icons.check),
            iconSize: 30,
            color: Colors.grey.withAlpha(100),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      // Replace 'YourString' with the actual string you want to return
                      Navigator.pop(context, '');
                    },
                    icon: const Icon(Icons.delete),
                    iconSize: 30,
                    color: Colors.grey.withAlpha(100)),
              ],
            )
          ],
          backgroundColor: const Color.fromARGB(255, 0, 7, 18),
        ),
        body: Container(
          decoration: const BoxDecoration(color: Color(0xFF010B1C)),
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 60),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 999999,
            decoration: InputDecoration.collapsed(
              hintText: 'Note...',
              hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
            ),
          ),
        ),
      ),
    );
  }
}
