import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_handler/model/template.dart';//delete later
import 'package:pdf_handler/pages/login_page.dart';
import 'package:pdf_handler/pages/search_customer.dart';//delete later
import 'package:pdf_handler/pages/search_template.dart';//delete later
import 'package:pdf_handler/pages/create_template.dart';//delete later
import 'package:pdf_handler/pages/main_page.dart';//delete later
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

Future <void> main() async{
  //Ensures Flutter’s bindings are initialized before running async code
  WidgetsFlutterBinding.ensureInitialized();
  //Load the .env file
  await dotenv.load(fileName: '.env');
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
      home: const MainPage(nickname: 'bahligger', uid: 2),// ⚠️will change this to login page later⚠️.
    );
  }
}
