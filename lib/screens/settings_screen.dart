import 'package:flutter/material.dart';
import 'package:gospl/main.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/services/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService auth = AuthService();
  final String username = (isar.appUsers.getSync(0))!.name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: RadialGradient(colors: [
          Color(0xff76aad5),
          Color(0xff1f64a1),
          Color.fromARGB(255, 4, 47, 94),
          Color.fromARGB(255, 1, 30, 65),
          Color.fromARGB(255, 1, 16, 37),
          Color.fromARGB(255, 0, 10, 28)
        ], center: Alignment.topCenter, radius: 1.5)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox.square(
                      dimension: 110,
                      child: Transform.flip(
                          flipX: true,
                          child: Image.asset(
                            'assets/leaf_decoration.png',
                          ))),
                  Transform.scale(
                    scale: 2.6,
                    origin: const Offset(0, -10),
                    child: Row(
                      children: [
                        SizedBox.square(
                          dimension: 30,
                          child: TextButton(
                            style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color.fromARGB(210, 255, 255, 255),
                              size: 12,
                            ),
                            onPressed: () {
                              Navigator.pop(context, null);
                            },
                          ),
                        ),
                        Text(
                          'Settings',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade100, fontSize: 13, letterSpacing: 1.2),
                        ),
                        const SizedBox.square(
                          dimension: 15,
                        ),
                      ],
                    ),
                  ),
                  SizedBox.square(
                      dimension: 110,
                      child: Image.asset(
                        'assets/leaf_decoration.png',
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(40, 40, 20, 40),
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.grey.shade200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account:',
                        style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                style: const ButtonStyle(
                                  minimumSize: MaterialStatePropertyAll(Size(10, 30)),
                                  padding: MaterialStatePropertyAll(EdgeInsets.all(3)),
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                                ),
                                onPressed: () {
                                  auth.signOut();
                                  Navigator.pop(context);
                                },
                                child: const Row(
                                  children: [Icon(Icons.person), Text('Sign Out')],
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              ElevatedButton(
                                style: const ButtonStyle(
                                  minimumSize: MaterialStatePropertyAll(Size(10, 30)),
                                  padding: MaterialStatePropertyAll(EdgeInsets.all(5)),
                                  textStyle: MaterialStatePropertyAll(TextStyle(color: Colors.white38)),
                                  backgroundColor: MaterialStatePropertyAll(Colors.red),
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                                              const Text('Delete account? This cannot be undone!'),
                                              ElevatedButton(
                                                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
                                                onPressed: () {
                                                  showDialog(context: context, builder: (context) => const AreYouSureDialog());
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              )
                                            ]),
                                          ),
                                        );
                                      });
                                },
                                child: const Text(
                                  'Delete Account',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        style: const ButtonStyle(minimumSize: MaterialStatePropertyAll(Size.zero), padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                        onPressed: () {
                          showLicensePage(context: context);
                        },
                        child: const Text('Licenses'),
                      ),
                      TextButton(
                        style: const ButtonStyle(minimumSize: MaterialStatePropertyAll(Size.zero), padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                        onPressed: () async {
                          var uri = Uri(scheme: 'https', host: 'www.termsfeed.com', path: '/live/1fbfc706-8a3d-44bb-b794-aed8feb552de');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            
                          }
                        },
                        child: const Text('Terms and Conditions'),
                      ),
                      TextButton(
                        style: const ButtonStyle(minimumSize: MaterialStatePropertyAll(Size.zero), padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                        onPressed: () async {
                          var uri = Uri(scheme: 'https', host: 'www.termsfeed.com', path: '/live/cfdab64f-d771-4d16-bdc0-0b1b12e2e041');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            
                          }
                        },
                        child: const Text('Privacy Policy'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AreYouSureDialog extends StatefulWidget {
  const AreYouSureDialog({
    super.key,
  });

  @override
  State<AreYouSureDialog> createState() => _AreYouSureDialogState();
}

class _AreYouSureDialogState extends State<AreYouSureDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Are you sure?'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Dialog(clipBehavior: Clip.hardEdge, child: SignInConfirmDelete());
                      });
                },
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green)),
                child: const Text('No', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SignInConfirmDelete extends StatefulWidget {
  const SignInConfirmDelete({super.key});

  @override
  State<SignInConfirmDelete> createState() => _SignInConfirmDeleteState();
}

class _SignInConfirmDeleteState extends State<SignInConfirmDelete> {
  TextStyle formTextStyle = const TextStyle(color: Colors.grey);
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text('For security reasons, please enter your email and password'),
          TextFormField(
            style: formTextStyle,
            decoration: const InputDecoration(
              hintText: 'Email',
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(5))),
            ),
            validator: (val) => val!.isEmpty ? 'Enter an email' : null,
            onChanged: (val) {
              setState(() {
                email = val;
              });
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            style: formTextStyle,
            decoration: const InputDecoration(
              hintText: 'Password',
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(5))),
            ),
            validator: (val) => val!.length < 8 ? 'Password must be at least 8 characters long' : null,
            obscureText: true,
            onChanged: (val) {
              setState(() {
                password = val;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
            onPressed: () async {
              AuthService auth = AuthService();
              await auth.signOut();
              await auth.deleteWithEmailAndPassword(email: email, password: password).then(
                    (value) {},
                  );
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 4);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
