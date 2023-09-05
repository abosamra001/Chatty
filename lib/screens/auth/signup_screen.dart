import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/widgets/auth_icons.dart';
import 'package:chat_app/helper/theme.dart';
import 'package:chat_app/helper/extensions.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  File? _selectedImage;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _userNameController = TextEditingController();
  final _userPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passController.dispose();
    _userNameController.dispose();
    _userPhoneController.dispose();
  }

  void _pickAndCropImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (image == null) {
      return;
    }
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
    if (croppedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(croppedImage.path);
    });
  }

  void _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Note'),
          content:
              Text('We will send to ${_emailController.text} a verification '
                  'email make sure you have entered your correct email.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _verify();
              },
              child: const Text('Ok'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );
    } else {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    }
  }

  Future<void> _verify() async {
    final auth = FirebaseAuth.instance;
    final storageRef = FirebaseStorage.instance.ref();
    final db = FirebaseFirestore.instance;
    Navigator.of(context).pop();
    setState(() {
      _isLoading = true;
    });
    try {
      await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );
      //TODO: enable email verification

      // await auth.currentUser!.sendEmailVerification();
      await auth.currentUser!.updateDisplayName(_userNameController.text);
      if (_selectedImage != null) {
        final userProfileImageRef = storageRef
            .child('user_profile_image')
            .child(
                '${auth.currentUser!.uid}${p.extension(_selectedImage!.path)}');
        await userProfileImageRef.putFile(_selectedImage!);
        final imageURL = await userProfileImageRef.getDownloadURL();
        await auth.currentUser!.updatePhotoURL(imageURL);
      }
      await db.collection('users_data').doc(auth.currentUser!.uid).set({
        'username': _userNameController.text,
        'phone': _userPhoneController.text,
        'email': _emailController.text,
      });
      _verifyDone();
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.code.wellFormatted);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _verifyDone() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text(
          'Verification link sent successfully '
          'tap the link to verify your account then log in normaly',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
            child: const Text('Done'),
          )
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MySignUpTheme.toggleTheme(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  'assets/images/signup5.png',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                InkWell(
                  onTap: _selectedImage == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => Container(
                                color: Colors.black,
                                height: double.infinity,
                                width: double.infinity,
                                child: Image.file(_selectedImage!),
                              ),
                            ),
                          );
                        },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: const AssetImage(
                            'assets/images/user.png',
                          ),
                          foregroundImage: _selectedImage == null
                              ? null
                              : FileImage(_selectedImage!),
                        ),
                        CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          radius: 14,
                          child: IconButton(
                            iconSize: 13,
                            onPressed: _pickAndCropImage,
                            icon: const FaIcon(
                              FontAwesomeIcons.camera,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _userNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required.';
                          }
                          if (!value.isValidUserName) {
                            return 'Enter a valid username.';
                          }
                          return null;
                        },
                        decoration: customDecoration(
                          context,
                          hintText: 'Username',
                          prefix: Icons.person,
                        ),
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: Color(0xff455a64)),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _userPhoneController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required.';
                          }
                          if (!value.isValidPhone) {
                            return 'Enter a valid phone number.';
                          }
                          return null;
                        },
                        maxLength: 11,
                        decoration: customDecoration(
                          context,
                          hintText: 'Phone',
                          prefix: Icons.phone,
                        ),
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: Color(0xff455a64)),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),
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
                      const SizedBox(height: 15),
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
                          prefix: Icons.lock,
                          hintText: 'Password',
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
                          _signUpUser();
                        },
                        style: const TextStyle(color: Color(0xff455a64)),
                        obscureText: _obscure,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signUpUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          minimumSize: const Size(230, 45),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 10,
                                width: 10,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const Text(
                                'Sign Up',
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
                          const Text('Already have an account? '),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AuthIcons(
                        color: theme.primaryColor,
                        text: 'Sign Up with',
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
