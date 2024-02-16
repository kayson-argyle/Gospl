import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gospl/models/user.dart';
import 'package:gospl/random_stuff/faux_upper_case_text.dart';
import 'package:gospl/services/auth.dart';
import 'package:gospl/shared/loading.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key, required this.toggleView});
  final Function toggleView;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  TextStyle formTextStyle = const TextStyle(color: Colors.grey);

  // text field state
  String email = '';
  String password = '';
  String error = '';

  late TapGestureRecognizer signUp;

  @override
  void initState() {
    signUp = TapGestureRecognizer()
        ..onTap = () {
          widget.toggleView();
        };
    super.initState();
  }

  @override
  void dispose() {
    signUp.dispose();
    super.dispose();
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
                text: 'Sign in',
                fontSize: 20,
                style: TextStyle(color: Color.fromARGB(255, 91, 45, 28)),
              ),
            ),
            body: Container(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    const SizedBox(height: 30),
                    Expanded(child: Image.asset('assets/Gospl_Logo_transparent.png')),
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
                    ElevatedButton(
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blueAccent)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          AppUser? result = await _auth.signInWithEmailAndPassword(email.trim(), password.trim());
                          if (result == null) {
                            setState(() {
                              loading = false;
                              error = 'Email or password incorrect';
                            });
                          }
                        }
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(text: "Don't have an Account? "),
                          TextSpan(
                            text: 'Register.',
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            recognizer: signUp,
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
                  ]),
                )),
          );
  }
}
