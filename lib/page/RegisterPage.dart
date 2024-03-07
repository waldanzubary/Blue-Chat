import 'package:bluechat/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:bluechat/komponen/ButtonController.dart';
import 'package:bluechat/komponen/FieldText.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  final void Function()? onTap;

  const Register({Key? key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  void signUp() async {
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username Wajib Di isi')),
      );
      return;
    }

    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email Wajib Di Isi')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords tidak Sama')),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailandPassword(
        emailController.text,
        passwordController.text,
        usernameController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    "Bikin Akun Baru...",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  FieldText(
                    controller: usernameController,
                    hintText: 'username...',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  FieldText(
                    controller: emailController,
                    hintText: 'email...',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  FieldText(
                    controller: passwordController,
                    hintText: 'Password...',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  FieldText(
                    controller: confirmPasswordController,
                    hintText: 'Konfirmasi Password...',
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  ButtonController(onTap: signUp, text: 'Buat Akun'),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
