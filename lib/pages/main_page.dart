import 'package:flutter/material.dart';

class MainPage extends StatelessWidget{
  final String nickname;
  final int uid;
  const MainPage({super.key, required this.nickname, required this.uid});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: Center(
        child: Text('Logged in as user: $nickname with id: $uid'),
      ),
    );
  }
}