import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

class SearchTemplate extends StatefulWidget {
  const SearchTemplate({super.key});
  @override
  State<SearchTemplate> createState() => _SearchTemplateState();
}

class _SearchTemplateState extends State<SearchTemplate> {
  _SearchTemplateState();

  late ScrollController _scrollController;

  @override
  void initState() {
    // initialize scroll controllers
    _scrollController = ScrollController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: Center(
        child: WebSmoothScroll(
          controller: _scrollController,
          scrollSpeed: 3,
          scrollAnimationLength: 500,
          curve: Curves.decelerate,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Select Template',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 46, 46, 46),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(255, 202, 202, 202),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 24,
                      ),
                      hintText: 'Search Template...',
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const double itemWidth = 300;
                      int crossAxisCount =
                          (constraints.maxWidth / itemWidth).floor();
                      crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: List.generate(10, (index) {
                          return Card(
                            elevation: 3,
                            child: Center(child: Text('Card ${index + 1}')),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
