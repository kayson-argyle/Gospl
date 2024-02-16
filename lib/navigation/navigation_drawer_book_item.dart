import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gospl/random_stuff/faux_upper_case_text.dart';

class NavigationDrawerBookItem extends StatelessWidget {
  const NavigationDrawerBookItem({super.key, required this.text, required this.icon, required this.function, required this.collectionId});

  final IconData icon;
  final String text;
  final Function function;
  final String collectionId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: InkWell(
        splashColor: Colors.white.withAlpha(40),
        radius: 145,
        onTap: () {
            function(text, collectionId);
          },
        child: Container(
          padding: const EdgeInsets.only(bottom: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.white.withAlpha(70),
              ])),
          child: Row(
            children: [
              const SizedBox(
                width: 6,
              ),
              Container(
                alignment: Alignment.center,
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 235, 187, 169),
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  gradient: const LinearGradient(colors: [Color.fromARGB(255, 25, 60, 61), Color.fromARGB(255, 18, 101, 104)]),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: const Color.fromARGB(255, 255, 224, 213),
                ),
              ),
              const SizedBox(width: 16),
              FauxUpperCaseText(text: text, style: GoogleFonts.tinos(),)
            ],
          ),
        ),
      ),
    );
  }
}

