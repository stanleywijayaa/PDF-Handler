import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/pages/search_customer.dart';
import 'package:pdf_handler/services/template_logic.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

class SearchTemplate extends StatefulWidget {
  const SearchTemplate({super.key});
  @override
  State<SearchTemplate> createState() => _SearchTemplateState();
}

class _SearchTemplateState extends State<SearchTemplate> {
  late ScrollController _scrollController;
  Template? selectedTemplate;
  late Future<List<Template>> _futureTemplates;

  @override
  void initState() {
    // initialize scroll controllers
    super.initState();
    _scrollController = ScrollController();
    _futureTemplates = TemplateLogic.fetchTemplate("abccc");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: WebSmoothScroll(
        controller: _scrollController,
        scrollAnimationLength: 400,
        scrollSpeed: 2,
        curve: Curves.linear,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          controller: _scrollController,
          child: Center(
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
                  FutureBuilder<List<Template>>(
                    future: _futureTemplates,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No templates found');
                      }

                      final templates = snapshot.data!;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          const double itemWidth = 200;
                          int crossAxisCount =
                              (constraints.maxWidth / itemWidth).floor();
                          crossAxisCount =
                              crossAxisCount > 0 ? crossAxisCount : 1;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1,
                                ),
                            itemCount: templates.length,
                            itemBuilder: (context, index) {
                              final template = templates[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTemplate = template;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SearchCustomer(
                                            template: selectedTemplate,
                                          ),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.picture_as_pdf,
                                          size: 48,
                                          color: Color.fromARGB(
                                            255,
                                            46,
                                            46,
                                            46,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          template.title ?? 'Untitled',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${template.fileSize ?? 0} KB',
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
