import 'package:flutter/material.dart';

class ChatContainer extends StatelessWidget {
  final String message;
  const ChatContainer({super.key,
  required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white
        ),
      ),
    );
  }
}