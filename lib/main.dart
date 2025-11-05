import 'package:flutter/material.dart';

void main() {
  runApp(const PDFHandler());
}

class PDFHandler extends StatelessWidget {
  const PDFHandler({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),fontFamily: 'Arial'),'PDF Handler 3000'),
          centerTitle: true
          ),
      )
    );
  }
}