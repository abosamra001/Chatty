import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:chat_app/widgets/auth_icons.dart';
import 'package:chat_app/screens/auth/signup_screen.dart';
import 'package:chat_app/helper/extensions.dart';
import 'package:chat_app/helper/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
  }

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final auth = FirebaseAuth.instance;
      try {
        await auth
            .signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passController.text,
            )
            .then(
              (_) => setState(() {
                _isLoading = false;
              }),
            );
        // TODO: uncomment this
        // if (!auth.currentUser!.emailVerified) {
        //   _reVerifyUser();
        // }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(msg: e.code.wellFormatted);
      }
    } else {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    }
  }

  void _reVerifyUser() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify your email'),
        content: const Text('This email is need to be verified.'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser!.sendEmailVerification();
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _resetPassword() {
    if (_emailController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reset your password'),
          content: Text(
              'A link will be sent to ${_emailController.text} if this is not '
              'the correct click Cancel otherwise click Ok.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: _emailController.text);
                } on FirebaseAuthException catch (e) {
                  Fluttertoast.showToast(msg: e.code);
                }
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    } else {
      Fluttertoast.showToast(msg: 'enter your email first.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MyLogInTheme.toggleTheme(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/images/login.png',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Log In',
                        style: TextStyle(
                          color: theme.forgroundColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 42,
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required.';
                          }
                          if (!value.isValidEmail) {
                            return 'Enter a valid email.';
                          }
                          return null;
                        },
                        decoration: customDecoration(
                          context,
                          hintText: 'Email',
                          prefix: Icons.email,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          if (!value.isValidPassword) {
                            return 'Enter a valid password';
                          }
                          return null;
                        },
                        decoration: customDecoration(
                          context,
                          hintText: 'Password',
                          prefix: Icons.lock,
                          suffix: IconButton(
                            iconSize: 20,
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                            icon: Icon(
                              _obscure
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeLowVision,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          _loginUser();
                        },
                        style: const TextStyle(color: Color(0xff455a64)),
                        obscureText: _obscure,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _resetPassword,
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(color: theme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          minimumSize: const Size(230, 45),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.forgroundColor,
                                  ),
                                ),
                              )
                            : const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account? '),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AuthIcons(
                        color: theme.primaryColor,
                        text: 'Log In with',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration customDecoration(BuildContext context,
    {required String hintText, required IconData prefix, IconButton? suffix}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xff455a64),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 16,
    ),
    prefixIcon: Icon(prefix),
    prefixIconColor: const Color(0xff455a64),
    suffixIcon: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(
        color: Colors.blue,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),
  );
}
