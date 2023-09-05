import 'package:chat_app/helper/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _signOutUser() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: const Text('Sign out'),
        content: const Text('Are sure you need to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
              } on FirebaseAuthException catch (e) {
                Fluttertoast.showToast(msg: e.code.wellFormatted);
              }
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final docRef =
        FirebaseFirestore.instance.collection('users_data').doc(user!.uid);
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading...'),
              );
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(
                child: Text('There is no data yet, or something wrong ocured'),
              );
            }
            final data = snapshot.data!.data();
            if (data == null) {
              return const Center(
                child: Text(' data = null.'),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Welcome '),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(
                      user.photoURL ??
                          'https://i.pinimg.com/originals/76/66/bd/7666bdafe70b15ff813cddf37ffe35a8.jpg',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(data['username'] ?? 'Mr. NoBody'),
                  const SizedBox(height: 15),
                  Text(user.email!),
                  const SizedBox(height: 15),
                  Text(data['phone']),
                  TextButton(
                    onPressed: _signOutUser,
                    child: const Text('Sign out'),
                  ),
                  const SizedBox(height: 50),
                  // Text('${FirebaseAuth.instance.currentUser}'),
                ],
              ),
            );
          }),
    );
  }
}
