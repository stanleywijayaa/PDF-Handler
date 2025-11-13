import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_handler/pages/login_page.dart';
import 'package:pdf_handler/pages/select_template.dart';
import 'package:pdf_handler/pages/create_template.dart';

class MainPage extends StatelessWidget {
  final String nickname;
  final int uid;
  const MainPage({super.key, required this.nickname, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nickname),
                      Text(
                        'ID: ${uid.toString()}',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                'PDF Template Manager',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 46, 46, 46),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      ),
                  icon: Icon(Icons.logout),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _button(context, "Create Template", CreateTemplate(uid: uid)),
              _button(context, "Search Template", SelectTemplate(uid: uid)),
            ],
          ),
        ),
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
