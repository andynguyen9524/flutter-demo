import 'package:flutter/material.dart';

class WordViewScreen extends StatefulWidget {
  const WordViewScreen({super.key});

  @override
  State<WordViewScreen> createState() => _WordViewScreenState();
}

class _WordViewScreenState extends State<WordViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word View'), centerTitle: true),
      body: Center(child: Text('This is the Word View Screen')),
    );
  }
}
