import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_handler/pages/search_template.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const PDFHandler());
}

class PDFHandler extends StatelessWidget {
  const PDFHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Template App',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SearchTemplate(),
    );
  }
}
