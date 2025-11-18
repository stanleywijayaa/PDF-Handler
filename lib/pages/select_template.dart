import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_handler/model/template.dart';
import 'package:pdf_handler/pages/create_template.dart';
import 'package:pdf_handler/pages/login_page.dart';
import 'package:pdf_handler/pages/search_customer.dart';
import 'package:pdf_handler/services/template_logic.dart';
import 'package:pdf_handler/services/user_logic.dart';
import 'package:pdfx/pdfx.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

class SelectTemplate extends StatefulWidget {
  final String nickname;
  final int uid;
  const SelectTemplate({super.key, required this.nickname, required this.uid});
  @override
  State<SelectTemplate> createState() => _SelectTemplateState();
}

class _SelectTemplateState extends State<SelectTemplate> {
  late ScrollController _scrollController;
  Template? selectedTemplate;
  late Future<List<Template>> _futureTemplates = Future.value([]);
  late List<Template> _allTemplates = [];
  List<Template> _displayedTemplates = [];

  @override
  void initState() {
    // initialize scroll controllers
    super.initState();
    _scrollController = ScrollController();
    _loadData();
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _futureTemplates = Future.value([]);
    _allTemplates = [];
    _displayedTemplates = [];
  }

  Future<void> _loadData() async {
    final nocoApp = await UserLogic.getNocoApp(widget.uid);
    if (!mounted) return;
    setState(() {
      if (nocoApp == null) {
        _futureTemplates = Future.value([]);
      } else {
        _futureTemplates = TemplateLogic.fetchTemplate(nocoApp);
      }
    });
    _allTemplates = await _futureTemplates;
    _displayedTemplates = _allTemplates;
  }

  void _searchTemplate(String value) {
    if (value.isEmpty) {
      if (!mounted) return;
      setState(() {
        _displayedTemplates = _allTemplates;
      });
    }
    List<Template> filteredTemplates =
        _allTemplates
            .where(
              (element) =>
                  element.tableName.toLowerCase().contains(
                    value.toLowerCase(),
                  ) ||
                  element.title.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();
    if (!mounted) return;
    setState(() {
      _displayedTemplates = filteredTemplates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTemplate(uid: widget.uid),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
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
                  Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back),
                        ),
                      ),
                      Align(
                        alignment: AlignmentGeometry.center,
                        child: Text(
                          'PDF Template Manager',
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 46, 46, 46),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    onChanged: (value) => _searchTemplate(value),
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
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: FutureBuilder<List<Template>>(
                      future: _futureTemplates,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text(
                            'No templates found',
                            style: TextStyle(color: Colors.black),
                          );
                        }

                        final templates = _displayedTemplates;

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            const double itemWidth = 250;
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
                                    //crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: templates.length,
                              itemBuilder: (context, index) {
                                final template = templates[index];
                                return InkWell(
                                  radius: 12,
                                  hoverColor: Color.fromARGB(
                                    100,
                                    200,
                                    200,
                                    200,
                                  ),
                                  onTap: () {
                                    if (!mounted) return;
                                    setState(() {
                                      selectedTemplate = template;
                                    });
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: '',
                                      barrierColor: Colors.black54,
                                      transitionDuration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      pageBuilder: (context, anim1, anim2) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(48),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              child: Container(
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                                child: SearchCustomer(
                                                  template: template,
                                                  uid: widget.uid,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    elevation: 3,
                                    color: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          PdfFirstPagePreview(
                                            template: template,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            template.title,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.nunito(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${template.fileSize} KB',
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

class PdfFirstPagePreview extends StatefulWidget {
  final Template template;
  const PdfFirstPagePreview({super.key, required this.template});

  @override
  State<PdfFirstPagePreview> createState() => _PdfFirstPagePreviewState();
}

class _PdfFirstPagePreviewState extends State<PdfFirstPagePreview> {
  PdfDocument? _document;
  PdfPageImage? _pageImage;
  TemplateLogic templateLogic = TemplateLogic();
  bool _loading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    if (widget.template.preview == null) {
      try {
        // Open the document (from file, asset, or URL)
        final bytes = await templateLogic.getTemplate(
          templateId: widget.template.id,
        );
        if (_isDisposed) return;
        if (bytes == null) throw Exception('Failed to get template');
        final doc = await PdfDocument.openData(bytes);
        if (_isDisposed) {
          doc.close();
          return;
        }
        final page = await doc.getPage(1);
        if (_isDisposed) {
          doc.close();
          page.close();
          return;
        }

        // Render it to an image
        final pageImage = await page.render(
          width: page.width / 2.5,
          height: page.height / 2.5,
          quality: 100,
          format: PdfPageImageFormat.png,
        );
        if (_isDisposed) {
          doc.close();
          page.close();
          return;
        }

        widget.template.preview = pageImage;

        await page.close();

        if (!mounted || _isDisposed) return;

        setState(() {
          _document = doc;
          _pageImage = pageImage;
          _loading = false;
        });
      } catch (e) {
        if (!mounted || _isDisposed) return;
        setState(() => _loading = false);
      }
    } else {
      if (!mounted || _isDisposed) return;
      setState(() {
        _pageImage = widget.template.preview;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _document?.close();
    super.dispose();
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _pageImage != null
              ? Image.memory(
                _pageImage!.bytes,
                scale: 1,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              )
              : const Center(child: Icon(Icons.picture_as_pdf, size: 40)),
    );
  }
}
