import 'package:chat_app/helper/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthIcons extends StatelessWidget {
  const AuthIcons({super.key, required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                endIndent: 10,
                thickness: 0.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const Text(
              'OR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Divider(
                indent: 10,
                thickness: 0.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
        Text(text),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                try {
                  final googleUser = await GoogleSignIn().signIn();
                  if (googleUser == null) {
                    return;
                  }
                  final googleAuth = await googleUser.authentication;

                  final credential = GoogleAuthProvider.credential(
                    accessToken: googleAuth.accessToken,
                    idToken: googleAuth.idToken,
                  );
                  await FirebaseAuth.instance.signInWithCredential(credential);
                } on FirebaseAuthException catch (e) {
                  Fluttertoast.showToast(msg: e.code.wellFormatted);
                }
              },
              icon: FaIcon(
                FontAwesomeIcons.google,
                color: color,
                size: 35,
              ),
            ),
            IconButton(
              onPressed: () async {
                try {
                  final loginResult = await FacebookAuth.instance.login();

                  final authCredential = FacebookAuthProvider.credential(
                    loginResult.accessToken!.token,
                  );
                  await FirebaseAuth.instance
                      .signInWithCredential(authCredential);
                } catch (e) {
                  Fluttertoast.showToast(msg: e.toString());
                }
              },
              icon: FaIcon(
                FontAwesomeIcons.facebook,
                color: color,
                size: 35,
              ),
            ),
            IconButton(
              onPressed: () {
                print(
                    '===================== ${FirebaseAuth.instance.currentUser}');
              },
              icon: FaIcon(
                FontAwesomeIcons.github,
                color: color,
                size: 35,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
