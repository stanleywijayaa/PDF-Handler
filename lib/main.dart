import 'package:flutter/material.dart';
import 'pages/login_page.dart';
void main() {
  runApp(const PDFHandler());
}

class PDFHandler extends StatelessWidget {
  const PDFHandler({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Template App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}