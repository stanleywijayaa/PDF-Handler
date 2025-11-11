import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_handler/pages/search_template.dart';
import 'package:pdf_handler/pages/create_template.dart';

class MainPage extends StatelessWidget {
  final String nickname;
  final int uid;
  const MainPage({super.key, required this.nickname, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page Logged in as user: $nickname with id: $uid'),
      ),
      body: Column(
        children: [
          Text(
            'Select Template',
            style: GoogleFonts.nunito(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 46, 46, 46),
            ),
          ),
          const SizedBox(height: 10),
          _button(context, "Create Template Page", CreateTemplate(uid: uid)),
          _button(context, "Search Template Page", SearchTemplate(uid: uid)),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          minimumSize: const Size(200, 50),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
