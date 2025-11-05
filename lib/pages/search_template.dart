import 'package:flutter/material.dart';

class SearchTemplate extends StatefulWidget {
  const SearchTemplate({super.key});
  @override
  State<SearchTemplate> createState() => _SearchTemplateState();
}

class _SearchTemplateState extends State<SearchTemplate> {
  _SearchTemplateState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 240, 240),
      body: Row(
        children: [
          Text(
            'Search Template',
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
