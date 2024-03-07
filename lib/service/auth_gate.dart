import 'package:bluechat/service/LoginOrRegister.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bluechat/page/HomePage.dart';


class auth extends StatelessWidget {
  const auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges()
      , builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePage();

        }
        else{
          return const LoginOrRegister();
        }
      },),
    );
  }
}