import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.color = Colors.white, this.size = 50, this.backgroundColor = const Color(0xff010b1c), this.text = ''});
  final Color color;
  final double size;
  final String text;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
          children: text == ''
              ? ([
                  SpinKitWanderingCubes(
                    color: color,
                    size: size,
                  ),
                ])
              : ([
                const SizedBox(height: 20,),
                  Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  SpinKitWanderingCubes(
                    color: color,
                    size: size,
                  ),
                  const SizedBox(height: 20,),
                ])),
    );
  }
}
