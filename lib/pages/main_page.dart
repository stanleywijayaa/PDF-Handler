import 'package:flutter/material.dart';

class MainPage extends StatelessWidget{
  final String uid;
  const MainPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: Center(
        child: Text('Logged in as user with ID: $uid'),
      ),
    );
  }
}