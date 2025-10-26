import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _obscureText = true;
  var _isLoading = false;
  final _form = GlobalKey<FormState>();

  var _email = '';
  var _password = '';

  void _submit() async {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();

      setState(() {
        _isLoading = true;
      });
      try {
        if (!_isLogin) {
          final data = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: _email,
                password: _password,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account created successfully!"),
              duration: Duration(milliseconds: 1100),
              backgroundColor: const Color.fromARGB(255, 0, 82, 3),
            ),
          );
        } else {
          final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Logged In successfully!"),
              duration: Duration(milliseconds: 1100),
              backgroundColor: const Color.fromARGB(255, 0, 82, 3),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message!),
            duration: Duration(milliseconds: 1500),
            backgroundColor: const Color.fromARGB(255, 190, 13, 0),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } finally {
        if (mounted) {
          _isLoading = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _form,

              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Text(
                      _isLogin ? "Login" : "Signup",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                      ),
                    ),

                    SizedBox(height: 15),
                    TextFormField(
                      onSaved: (value) {
                        _email = value!;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      onSaved: (value) {
                        _password = value!;
                      },
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a password";
                        } else if (value.length < 8) {
                          return "Password must be at least 8 characters";
                        } else if (!value.contains(RegExp(r'[A-Z]'))) {
                          return "Include at least one uppercase letter";
                        } else if (!value.contains(RegExp(r'[a-z]'))) {
                          return "Include at least one lowercase letter";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          padding: EdgeInsets.only(right: 12),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            size: 22,
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                    SizedBox(height: 19),
                    _isLoading
                        ? CircularProgressIndicator.adaptive()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 35),
                            ),
                            onPressed: _submit,
                            child: Text(_isLogin ? "Login" : "Signup"),
                          ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? "Don't have an account?"
                            : "Already have an account?",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
