import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:gospl/main.dart";
import 'package:gospl/random_stuff/faux_upper_case_text.dart';
import "package:gospl/services/auth.dart";
import "package:gospl/shared/loading.dart";
import "package:url_launcher/url_launcher.dart";

class Register extends StatefulWidget {
  const Register({super.key, required this.toggleView});
  final Function toggleView;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  TextStyle formTextStyle = const TextStyle(color: Colors.grey);

  late TapGestureRecognizer hyperlink1;
  late TapGestureRecognizer hyperlink2;
  late TapGestureRecognizer signIn;

  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    hyperlink1 = TapGestureRecognizer()
      ..onTap = () async {
        var uri = Uri(scheme: 'https', host: 'www.termsfeed.com', path: '/live/1fbfc706-8a3d-44bb-b794-aed8feb552de');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {}
      };

    hyperlink2 = TapGestureRecognizer()
      ..onTap = () async {
        var uri = Uri(scheme: 'https', host: 'www.termsfeed.com', path: '/live/cfdab64f-d771-4d16-bdc0-0b1b12e2e041');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {}
      };
    signIn = TapGestureRecognizer()
      ..onTap = () {
        widget.toggleView();
      };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                  decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffe67c01), Color(0xfffff997)],
                ),
              )),
              elevation: 0,
              title: const FauxUpperCaseText(
                text: 'register',
                fontSize: 20,
                style: TextStyle(color: Color.fromARGB(255, 91, 45, 28)),
              ),
            ),
            body: Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Expanded(child: Image.asset('assets/Gospl_Logo_transparent.png')),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            style: formTextStyle,
                            decoration: const InputDecoration(
                              hintText: 'Username',
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(5))),
                            ),
                            validator: (val) => val!.length < 4 ? 'Username must be at least 4 characters long' : null,
                            onChanged: (val) {
                              setState(() {
                                username = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
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
                          TextFormField(
                            style: formTextStyle,
                            decoration: const InputDecoration(
                              hintText: 'Confirm Password',
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 2.0),
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink, width: 2.0), borderRadius: BorderRadius.all(Radius.circular(5))),
                            ),
                            validator: (val) => val! != password ? 'Passwords must match' : null,
                            obscureText: true,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blueAccent)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                preferences.setString('currentCollectionType', '');
                                setState(() {
                                  loading = true;
                                });
                                await _auth.registerWithEmailAndPassword(email.trim(), password.trim(), username.trim()).then((value) {
                                  if (value == null) {
                                    setState(() {
                                      loading = false;
                                      error = 'Please enter a valid email';
                                    });
                                  } else {
                                    firestoreUsers.doc(value.uid)
                                      ..set({'collaborative_scripture_collections': {}, 'numberOfOwnedCollections': 0, 'username': username, 'accountCreatedDate': DateTime.now()})
                                      ..collection('collaborative_scripture_collections').doc(value.uid).set({});
                                  }
                                  return null;
                                });
                              }
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                const TextSpan(text: 'By creating an account, you agree to\nour '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: hyperlink1,
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(color: Colors.blue),
                                  recognizer: hyperlink2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                const TextSpan(text: "Already have an Account? "),
                                TextSpan(
                                  text: 'Sign in.',
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  recognizer: signIn,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            error,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
