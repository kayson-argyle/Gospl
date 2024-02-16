import 'package:flutter/material.dart';

class ExpandableTextField extends StatefulWidget {
  const ExpandableTextField({super.key});

  @override
  ExpandableTextFieldState createState() => ExpandableTextFieldState();
}

class ExpandableTextFieldState extends State<ExpandableTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;


  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: AnimatedContainer(
              curve: Curves.easeInOutSine,
              duration: const Duration(milliseconds: 500),
              // width: _isFocused ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.5, // Change width
              // height: _isFocused ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.05,
              width: _isFocused ? 500 : 200,
              height: _isFocused ? 500 : 50,
              child: TextField(
                onTapOutside: (_) {
                  _focusNode.unfocus();
                },
                onTap: () {
                  _focusNode.requestFocus();
                },
                focusNode: _focusNode,
                maxLines: 99999999,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Note...',
                ),
              ),
            ),
    );
  }
}
