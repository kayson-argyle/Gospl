import 'package:flutter/material.dart';

class AboutTheDeveloper extends StatelessWidget {
  const AboutTheDeveloper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Image.asset(
                  'assets/queso.JPG',
                  width: 350,
                ),
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.all(30),
              child: const SelectableText(
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
                'Hi I’m Kayson, I made this app cause the Holy Ghost told me to. I LOVE Jesus. I’m 21, I’m going to college for Computer Science right now, and yes, I really am this pasty in real life. If you want to help me with this project, you can send me an email at: kayson.argyle@gospl.app\n\nEnjoy!',
              ))
        ],
      ),
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          'about the developer',
          style: TextStyle(color: Colors.white54),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
